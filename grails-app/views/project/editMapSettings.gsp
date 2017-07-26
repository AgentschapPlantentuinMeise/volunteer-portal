<!doctype html>
<html>
<head>
    <meta name="layout" content="digivol-projectSettings"/>
</head>

<body class="continer">


<content tag="pageTitle"><g:message code="project.map_settings.map"/></content>

<content tag="adminButtonBar">
</content>

<g:set var="initZoom" value="${projectInstance.mapInitZoomLevel ?: 3}"/>
<g:set var="initLatitude" value="${projectInstance.mapInitLatitude ?: -27.76133033947936}"/>
<g:set var="initLongitude" value="${projectInstance.mapInitLongitude ?: 134.47265649999997}"/>

<g:form method="post" class="form-horizontal" name="updateForm" action="updateMapSettings">

    <g:hiddenField name="id" value="${projectInstance?.id}"/>
    <g:hiddenField name="version" value="${projectInstance?.version}"/>

    <div class="form-group">
        <label for="showMap" class="checkbox col-md-6">
            <g:message code="project.map_settings.map.show_on_landing_page"/>
        </label>
        <div class="col-md-6">
            <g:checkBox name="showMap"
                        checked="${projectInstance.showMap}"/>
        </div>
    </div>

    <div class="alert alert-warning">
        <g:message code="project.map_settings.map.position_the_map"/>
    </div>

    <div class="row">
        <div class="col-md-6">
            <div class="thumbnail">
                <div id="recordsMap"></div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="row">
                <div class="form-group">
                    <label class="control-label col-md-4" for="mapZoomLevel"><g:message code="default.zoom.label"/></label>
                    <div class="col-md-6">
                        <g:textField name="mapZoomLevel" class="form-control" value="${initZoom}"/>
                    </div>
                </div>

                <div class="form-group">
                    <label class="control-label col-md-4" for="mapLatitude"><g:message code="project.map_settings.map.center_latitude"/>:</label>
                    <div class="col-md-6">
                        <g:textField name="mapLatitude" class="form-control" value="${initLatitude}"/>
                    </div>
                </div>

                <div class="form-group">
                    <label class="control-label col-md-4" for="mapLongitude"><g:message code="project.map_settings.map.center_longitude"/>:</label>
                    <div class="col-md-6">
                        <g:textField name="mapLongitude" class="form-control" value="${initLongitude}"/>
                    </div>
                </div>

                <div class="form-group">
                    <div class="col-md-offset-4 col-md-8">
                        <g:actionSubmit class="save btn btn-primary" action="updateMapSettings"
                                        value="${message(code: 'default.button.update.label', default: 'Update')}"/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</g:form>

<script type='text/javascript' src='https://www.google.com/jsapi'></script>

<asset:script type='text/javascript'>

    google.load("maps", "3.23", {other_params: "key=${grailsApplication.config.google.maps.key}"});

    var map, infowindow;
    var mapListenerActive = true;

    $(document).ready(function () {

        $('#showMap').bootstrapSwitch({
            size: "small",
            onText: "${message(code:'default.yes')}",
            offText: "${message(code:'default.no')}"
        });

        bvp.bindTooltips();
        bvp.suppressEnterSubmit();

        $('#showMap').on('switchChange.bootstrapSwitch', function (event, state) {
            $("#updateForm").submit();
        });

        $("#btnNext").click(function (e) {
            e.preventDefault();
            bvp.submitWithWebflowEvent($(this));
        });

        loadMap();
        updateMapDisplay();
    });

    function loadMap() {

        var mapElement = $("#recordsMap");

        if (!mapElement) {
            return;
        }

        var myOptions = {
            scaleControl: false,
            center: new google.maps.LatLng(${initLatitude}, ${initLongitude}),
            zoom: ${initZoom},
            minZoom: 1,
            streetViewControl: false,
            scrollwheel: true,
            mapTypeControl: false,
            navigationControl: true,
            navigationControlOptions: {
                style: google.maps.NavigationControlStyle.SMALL // DEFAULT
            },
            mapTypeId: google.maps.MapTypeId.ROADMAP
        };

        map = new google.maps.Map(document.getElementById("recordsMap"), myOptions);

        google.maps.event.addListener(map, 'zoom_changed', function () {
            if (mapListenerActive) {
                updateFieldsFromMap();
            }
        });

        google.maps.event.addListener(map, 'center_changed', function () {
            if (mapListenerActive) {
                updateFieldsFromMap();
            }
        });
    }

    function updateFieldsFromMap() {
        var zoomLevel = map.getZoom();

        $("#mapZoomLevel").val(zoomLevel);

        var center = map.getCenter();
        $("#mapLatitude").val(center.lat());
        $("#mapLongitude").val(center.lng());
    }

    function updateMapDisplay() {
        if ($("#showMap").attr("checked")) {
            $("#mapPositionControls").css("opacity", "1");
        } else {
            $("#mapPositionControls").css("opacity", "0.2");
        }
    }

</asset:script>
</body>
</html>
