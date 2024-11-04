//**********************************************************************
// DESCRIPTION : Watch Faces for Trio
// AUTHORS :
//          Created by ivalkou - https://github.com/ivalkou
//          Modify by Pierre Lagarde - https://github.com/avouspierre
// COPYRIGHT : (c) 2023 ivalkou / Lagarde
//

import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;
import Toybox.Time;
import Toybox.System;
import Toybox.Communications;

(:background)
class TrioWatchfaceApp extends Application.AppBase {

    var inBackground=false;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        //register for temporal events if they are supported
        if(Toybox.System has :ServiceDelegate) {
            // canDoBG=true;
            Background.registerForTemporalEvent(new Time.Duration(5 * 60));
            if (Background has :registerForPhoneAppMessageEvent) {
                Background.registerForPhoneAppMessageEvent();
                System.println("****background is ok****");
            } else {
                System.println("****registerForPhoneAppMessageEvent is not available****");
            }

        } else {
            System.println("****background not available on this device****");
        }

        // Get the current Unix time
        var now = Time.now().value() as Number;

        // Subtract x minutes (x * 60 seconds) to get the timestamp for x minutes ago
        var lastLoopDateInterval = now - (4 * 60);

        // Simulate data for testing in the simulator
        var sampleData = {
            "glucose" => "188",
            "lastLoopDateInterval" => lastLoopDateInterval,
            "delta" => "-20",
            "iob" => "2.42",
            "cob" => "70.2",
            "isf" => "124",
            "eventualBGRaw" => "166",
            "trendRaw" => "FortyFiveDown"
        } as Dictionary;

        // Store the sample data , uncomment line below for testing in IQ sim
        // Application.Storage.setValue("status", sampleData);
    }

    function onBackgroundData(data) {
       if (data instanceof Number || data == null) {
                 System.println("Not a dictionary");
        } else {
                   System.println("try to update the status");
                   if (Background has :registerForPhoneAppMessageEvent) {
                        System.println("updated with registerForPhoneAppMessageEvent");
                        // Application.Storage.setValue("status", data as Dictionary);
                    } else {
                        System.println("update status");
                        Application.Storage.setValue("status", data as Dictionary);
                        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
                    }
            }
         System.println("requestUpdate");
         WatchUi.requestUpdate();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        if(!inBackground) {
            System.println("stop temp event");
    		Background.deleteTemporalEvent();
    	}
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TrioWatchfaceView() ] as [Views];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    function getServiceDelegate() {
        inBackground=true;
        System.println("start background");
        return [new TrioBGServiceDelegate()];
    }
}

function getApp() as TrioWatchfaceApp {
    return Application.getApp() as TrioWatchfaceApp;
}