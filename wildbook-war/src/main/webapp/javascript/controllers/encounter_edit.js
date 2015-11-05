wildbook.app.directive(
    'wbEncounterEdit',
    ["wbConfig", function($scope, $http, $exceptionHandler, wbConfig) {
        return {
            restrict: 'E',
            scope: {
                encounterToEdit: "@encounter",
                editEncounterDone: "&"
            },
            templateUrl: 'util/render?j=partials/encounter_edit',
            replace: true,
            controller($scope, $http, $exceptionHandler, wbConfig) {
                if ($scope.encounter === "new") {
                    $scope.encounter = {individual: {species: wbConfig.config().species[0]}};
                }
                
                function closePanel() {
                    $scope.editEncounterDone({encounter: $scope.encounter});
                }

                $scope.getSpecies = function() {
                    return wbConfig.config().species;
                }
                
                $scope.save = function() {
                    $http.post('obj/encounter/save', $scope.encounter)
                    .then(function(result) {
                        $scope.encounter.id = result.data;
                        closePanel();
                    }, $exceptionHandler);
                };
                
                //
                // wb-key-handler-form
                //
                $scope.cancel = function() {
                    $scope.encounter = null;
                    closePanel();
                }
                
                $scope.cmdEnter = function() {
                    $scope.save();
                }
            }
        };
    }]
);





//wildbook.app.controller("EncounterEditController", function($scope, $http, $exceptionHandler, wbConfig) {
//    var panelName = "encounter_edit";
//
//    $scope.$on(panelName, function(event, data) {
//        if (data) {
//            $scope.encounter = data;
//        } else {
//            $scope.encounter = {individual: {species: wbConfig.config().species[0]}};
//        }
//    });
//    
//    function closePanel() {
//        $scope.panels[panelName] = false;
//        $scope.$emit(panelName + "_done", $scope.encounter);
//    }
//
//    $scope.getSpecies = function() {
//        return wbConfig.config().species;
//    }
//    
//    $scope.save = function() {
//        $http.post('obj/encounter/save', $scope.encounter)
//        .then(function(result) {
//            $scope.encounter.id = result.data;
//            closePanel();
//        }, $exceptionHandler);
//    };
//    
//    //
//    // wb-key-handler-form
//    //
//    $scope.cancel = function() {
//        $scope.encounter = null;
//        closePanel();
//    }
//    
//    $scope.cmdEnter = function() {
//        $scope.save();
//    }
//});