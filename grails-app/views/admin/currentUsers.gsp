<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="au.org.ala.volunteer.Project" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
    <title><g:message code="admin.title" default="Administration - Current users"/></title>
</head>

<body class="admin" data-ng-app="currentUsers">

<cl:headerContent title="${message(code: 'default.currentUsers.label', default: 'Current User Activity')}">
    <%
        pageScope.crumbs = [
                [link: createLink(controller: 'admin'), label: message(code: 'default.admin.label', default: 'Admin')]
        ]
    %>
</cl:headerContent>

<div class="container-fluid">
    <div class="row">
        <div class="col-sm-12">

            <div data-ng-controller="CurrentUsersCtrl" class="panel panel-default ng-cloak" style="margin-top:1em">
                <div class="panel-heading"><g:message code="default.currentUsers.label"/>Current User Activity</div>

                <div class="panel-body">
                    {{activities.length}} <g:message code="admin.currentUsers" />
                    <small>(<g:message code="admin.last_refreshed" /> {{ lastRefreshed | date:'medium' }})</small>
                </div>
                <table class="table table-condensed table-striped table-bordered table-hover">
                    <thead>
                    <tr>
                        <th><g:message code="admin.user" /></th>
                        <th><g:message code="admin.ip" /></th>
                        <th><g:message code="admin.open_es" /></th>
                        <th><g:message code="admin.started" /></th>
                        <th><g:message code="admin.last_activity" /></th>
                        <th><g:message code="admin.last_request" /></th>
                    </tr>
                    </thead>
                    <tbody>
                        <tr data-ng-repeat="activity in activities">
                            <td>{{activity.userId}}</td>
                            <td><a ng-href="//freegeoip.net/json/{{activity.ip}}">{{activity.ip}}</a></td>
                            <td>{{activity.openESRequests}}</td>
                            <td>{{activity.timeFirstActivity | date:'medium' }} (<span data-am-time-ago="activity.timeFirstActivity"></span>)</td>
                            <td>{{activity.timeLastActivity | date:'medium' }} (<span data-am-time-ago="activity.timeLastActivity"></span>)</td>
                            <td>{{activity.lastRequest}}</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<asset:javascript src="digivol-module" asset-defer="" />
<asset:javascript src="angular/angular-moment" asset-defer=""/>
<asset:script type='text/javascript'>

    angular.module('currentUsers', ['digivol', 'angularMoment'])
      .controller("CurrentUsersCtrl",
        [ '$scope', '$interval', '$http',
        function($scope, $interval, $http) {
          $scope.lastRefreshed = new Date();
          $scope.activities = [];

          function refreshActivity() {
              $http.get('${createLink(controller: 'admin', action: 'userActivityInfo', format: 'json')}').then(function(resp) {
                $scope.activities = resp.data.activities;
                $scope.lastRefreshed = new Date();
              });
          }

          refreshActivity();
          $interval(refreshActivity, 5000);
        }
    ]);

</asset:script>
</body>
</html>
