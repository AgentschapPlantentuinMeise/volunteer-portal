package au.org.ala.volunteer

import org.springframework.validation.Errors
import org.springframework.web.context.request.RequestContextHolder

class TranscribeController {

    def fieldSyncService
    def auditService
    def taskService
    def authService
    def userService

    static allowedMethods = [saveTranscription: "POST"]

    def index = {
        if (params.id) {
            redirect(action: "showNextFromProject", params: params)
        } else {
            redirect(action: "showNextFromAny", params: params)
        }

    }

    def task = {

        def taskInstance = Task.get(params.id)
        def currentUser = authService.username()
        userService.registerCurrentUser()

        if (taskInstance) {
            //record the viewing of the task
            auditService.auditTaskViewing(taskInstance, currentUser)
            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)
            def isReadonly
            println(currentUser + " has role: " + authService.userInRole("ROLE_ADMIN"))

            if (taskInstance.fullyTranscribedBy && (taskInstance.fullyTranscribedBy != currentUser && !authService.userInRole("ROLE_ADMIN"))) {
                isReadonly = "readonly"
            }

            //retrieve the existing values
            Map recordValues = fieldSyncService.retrieveFieldsForTask(taskInstance)
            render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: recordValues, isReadonly: isReadonly])
        } else {
            redirect(view: 'list', controller: "task")
        }
    }

    def showNextAction = {
        println("rendering view: nextAction")
        def taskInstance = Task.get(params.id)
        render(view: 'nextAction', model: [id: params.id, taskInstance: taskInstance, userId: authService.username()])
    }

    /**
     * Retrieve the next un-transcribed record from any project, but supply one I havent seen,
     * or the least recently seen record.
     */
    def showNextFromAny = {

        def currentUser = authService.username()
        //println "current user = "+currentUser
        def taskInstance = taskService.getNextTask(currentUser)

        //retrieve the details of the template
        if (taskInstance) {
            redirect(action: 'task', id: taskInstance.id)
        } else {
            //TODO retrieve this information from the template
            render(view: 'noTasks')
        }
    }

    /**
     * Sync fields.
     * TODO record validation using the template information. Hoping some data validation
     *
     * done in the form.
     */
    def save = {
        def currentUser = authService.username()
        if (currentUser != null) {
            def taskInstance = Task.get(params.id)
            def project = Project.findById(taskInstance.project.id)
            def template = Template.findById(project.template.id)
            cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, true, false)
            if (!taskInstance.hasErrors()) {
                redirect(action: 'showNextAction', id: params.id)
            }
            else {
                render(view: template.viewName, model: [taskInstance: taskInstance, recordValues: params.recordValues])
            }
        } else {
            redirect(view: '../index')
        }
    }

    /**
     * Sync fields.
     *
     * TODO handle multiple records per submit.
     */
    def savePartial = {
        def currentUser = authService.username()
        if (currentUser) {
            def taskInstance = Task.get(params.id)
            cleanRecordValues(params.recordValues)
            fieldSyncService.syncFields(taskInstance, params.recordValues, currentUser, false, false)
            redirect(action: 'showNextAction', id: params.id)
        } else {
            redirect(view: '/index')
        }
    }

    /**
     * Remove strange chars from form fields (appear with ° symbols, etc)
     */
    def cleanRecordValues = { recordValues ->
        def idx = 0
        def hasMore = true
        while (hasMore) {
            def fieldValuesForRecord = recordValues.get(idx.toString())
            if (fieldValuesForRecord) {
                fieldValuesForRecord.each { keyValue ->
                    // remove strange chars from form fields TODO: find out why they are appearing 
                    keyValue.value = keyValue.value.replace("Â","").replace("Ã","")
                }

                idx = idx + 1
            } else {
                hasMore = false
            }
        }
    }

    def savePartial2 = {
        redirect(action: 'savePartial', id: params.id)
    }

    /**
     * Show the next task for the supplied project.
     */
    def showNextFromProject = {
        def currentUser = authService.username()
        def project = Project.get(params.id)

        def taskInstance = taskService.getNextTask(currentUser, project)

        //retrieve the details of the template
        if (taskInstance) {
            redirect(action: 'task', id: taskInstance.id)
        } else {
            render(view: 'noTasks')
        }
    }
}