//**********************************************************************
// DESCRIPTION : DataField for iAPS
// AUTHORS :
//          Created by ivalkou - https://github.com/ivalkou
//          Modify by Pierre Lagarde - https://github.com/avouspierre
// COPYRIGHT : (c) 2023 ivalkou / Lagarde
//

import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;


var height, width, center;
var xPosWatch;

class iAPSDataFieldView extends WatchUi.DataField {


    function initialize() {
        DataField.initialize();

    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        View.setLayout(Rez.Layouts.MainLayout(dc));

        width = dc.getWidth();
        center = width * 0.5;
        height = dc.getHeight();
        (View.findDrawableById("label") as Text).setText(Rez.Strings.label);
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        // See Activity.Info in the documentation for available information.

    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        var bgString;
        var loopColor;
        var loopString;
        var deltaString;

        var status = Application.Storage.getValue("status") as Dictionary;

        if (status == null) {
            bgString = "---";
            loopColor = getLoopColor(-1);
            loopString = "?";
            deltaString = "??";
        } else {
            var bg = status["glucose"] as String;
            bgString = (bg == null) ? "--" : bg as String;
            var min = getMinutes(status);
            loopColor = getLoopColor(min);
            loopString = (min < 0 ? "0'" : min.format("%d")) + "'" as String;
            deltaString = getDeltaText(status) as String;
        }
        // Set the background color
        //View.findDrawableById("Background").setColor(loopColor);
        (View.findDrawableById("Background") as Text).setColor(loopColor);    //getBackgroundColor());


        // Load layout elements
        var value = View.findDrawableById("value") as Text;
        var valueTime = View.findDrawableById("valueTime") as Text;
        var valueDelta = View.findDrawableById("valueDelta") as Text;
        var label = View.findDrawableById("label") as Text;
        var mLabel = "CGM";

        // Set the foreground color and value
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            label.setColor(Graphics.COLOR_WHITE);
            value.setColor(Graphics.COLOR_WHITE);
            valueTime.setColor(Graphics.COLOR_WHITE);
            valueDelta.setColor(Graphics.COLOR_WHITE);
        } else {
            label.setColor(Graphics.COLOR_BLACK);
            value.setColor(Graphics.COLOR_BLACK);
            valueTime.setColor(Graphics.COLOR_BLACK);
            valueDelta.setColor(Graphics.COLOR_BLACK);
        }

        if( bgString == null ) { bgString = "???"; }
        if( loopString == null ) { loopString = "?"; }
        if( deltaString == null ) { deltaString = "??"; }
        var yPosValue, yPosLabel;
        var xPosVerz, xPosDelta;
        var yPosVerzDelta;

        var fontVerzDelta = Graphics.FONT_LARGE;
        var fontSGV = bgString.length() <= 5 ? Graphics.FONT_NUMBER_HOT : Graphics.FONT_LARGE;
        var fontLabel = Graphics.FONT_MEDIUM;
        // Verschiebung oberes/unteres Datenfeld
        var korrektur1 = 6;
        //System.println(dc.getTextWidthInPixels(loopString, fontVerzDelta) + 5 + dc.getTextWidthInPixels(bgString, fontSGV) + 5 + dc.getTextWidthInPixels(deltaString, fontVerzDelta));
        //System.println(dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV));
        if( dc.getTextWidthInPixels(loopString, fontVerzDelta) + 5 + dc.getTextWidthInPixels(bgString, fontSGV) + 5 + dc.getTextWidthInPixels(deltaString, fontVerzDelta) > width
        || dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV) > height ) {
            fontVerzDelta = Graphics.FONT_MEDIUM;
            fontSGV = bgString.length() <= 5 ? Graphics.FONT_NUMBER_MEDIUM : Graphics.FONT_LARGE;
            fontLabel = Graphics.FONT_SYSTEM_TINY;
            korrektur1 = 3;
        }
        if ( dc.getTextWidthInPixels(loopString, fontVerzDelta) + 5 + dc.getTextWidthInPixels(bgString, fontSGV) + 5 + dc.getTextWidthInPixels(deltaString, fontVerzDelta) > width
        || dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV) > height + 3 ) {
            fontVerzDelta = Graphics.FONT_SYSTEM_TINY;
            fontSGV = bgString.length() <= 5 ? Graphics.FONT_SYSTEM_NUMBER_MILD : Graphics.FONT_SYSTEM_TINY;
            fontLabel = Graphics.FONT_SYSTEM_TINY;
            korrektur1 = 1;
        }
        if ( dc.getTextWidthInPixels(loopString, fontVerzDelta) + 5 + dc.getTextWidthInPixels(bgString, fontSGV) + 5 + dc.getTextWidthInPixels(deltaString, fontVerzDelta) > width
        || dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV) > height + 5 ) {
            fontVerzDelta = Graphics.FONT_SYSTEM_TINY;
            fontSGV = bgString.length() <= 5 ? Graphics.FONT_SYSTEM_MEDIUM : Graphics.FONT_SYSTEM_TINY;
            fontLabel = Graphics.FONT_SYSTEM_TINY;
            korrektur1 = -1;
            //System.println(dc.getTextWidthInPixels(loopString, fontVerzDelta) + 5 + dc.getTextWidthInPixels(bgString, fontSGV) + 5 + dc.getTextWidthInPixels(deltaString, fontVerzDelta));
            //System.println(dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV));
        }

        value.setFont(fontSGV);
        valueTime.setFont(fontVerzDelta);
        valueDelta.setFont(fontVerzDelta);
        label.setFont(fontLabel);

        var obscurityFlags = DataField.getObscurityFlags();

        var verschiebung = (dc.getFontHeight(fontLabel) - Toybox.Graphics.getFontAscent(fontSGV))/2;
        if( dc.getFontHeight(fontSGV) == Toybox.Graphics.getFontAscent(fontSGV) || bgString.length() > 5 ) {
            korrektur1 = -2;
        }
        if( obscurityFlags == 7 ) {
            // Oberes Datenfeld rundes Display, hier Tausch von BG und AAPS-Daten
            if( mLabel.equals("CGM") ){
                yPosLabel = height - Toybox.Graphics.getFontAscent(fontSGV) - dc.getFontHeight(fontLabel)/2 + korrektur1;
                yPosValue = height - Toybox.Graphics.getFontAscent(fontSGV)/2  + korrektur1;
                yPosVerzDelta = yPosValue;
            } else {
                yPosValue = height - dc.getFontHeight(fontLabel) - Toybox.Graphics.getFontAscent(fontSGV)/2 + korrektur1;
                yPosLabel = height - dc.getFontHeight(fontLabel)/2 - 1;
                yPosVerzDelta = height - dc.getFontHeight(fontLabel) - dc.getFontHeight(fontVerzDelta)/2;
            }
        } else if( obscurityFlags == 13 ) {
            // Unteres Datenfeld rundes Display
            yPosLabel = dc.getFontHeight(fontLabel)/2 - 2;
            yPosValue = dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontSGV)/2 - 3 - korrektur1;
            yPosVerzDelta = dc.getFontHeight(fontLabel) + Toybox.Graphics.getFontAscent(fontVerzDelta)/2 - 4 + korrektur1;
        } else {
            var edgeKorrektur =  obscurityFlags == 0 ? 2 : 0;
            yPosLabel = height/2 - dc.getFontHeight(fontLabel)/2 + verschiebung - edgeKorrektur + 1;
            yPosValue = height/2 + Toybox.Graphics.getFontAscent(fontSGV)/2 + verschiebung + edgeKorrektur - 1;
            yPosVerzDelta = yPosValue - edgeKorrektur;
        }
        var korrekturPos = dc.getTextWidthInPixels(loopString, fontVerzDelta) > dc.getTextWidthInPixels(deltaString, fontVerzDelta) ?
                0 : (dc.getTextWidthInPixels(deltaString, fontVerzDelta) - dc.getTextWidthInPixels(loopString, fontVerzDelta)) / 2 - 1;
        xPosWatch = width/2 - dc.getTextWidthInPixels(bgString, fontSGV)/2 - dc.getTextWidthInPixels(loopString, fontVerzDelta) - 24 - korrekturPos;
        xPosVerz = width/2 - dc.getTextWidthInPixels(bgString, fontSGV)/2 - 3 - korrekturPos;
        xPosDelta = width/2 + dc.getTextWidthInPixels(bgString, fontSGV)/2 + 2 - korrekturPos;

        value.setLocation(center - korrekturPos, yPosValue);
        valueTime.setLocation(xPosVerz, yPosVerzDelta);
        valueDelta.setLocation(xPosDelta, yPosVerzDelta);
        label.setLocation(center, yPosLabel);

        if ( bgString.length() > 5  &&  System.getDeviceSettings().phoneConnected == false ) {
            bgString = "Bluetooth!";
        }

        // Set text to display
        value.setText(bgString);
        valueTime.setText(loopString);
        valueDelta.setText(deltaString);


        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

    function getMinutes(status as Dictionary) as Number {
        //var status = Application.Storage.getValue("status") as Dictionary;
        //System.print(Time.now().value());
        if (status == null) {
            return -1;
        }
        var lastLoopDate = status["lastLoopDateInterval"] as Number;

        if (lastLoopDate == null) {
            return -1;
        }

        if (lastLoopDate instanceof Number) {


            var now = Time.now().value() as Number;

            var min = (now - lastLoopDate) / 60;
            return min;
        } else {
            return -1;
        }
    }

    function getLoopColor(min as Number) as Number {
        if (min < 0) {
            return getBackgroundColor() as Number;
        } else if (min <= 5) {
            return getBackgroundColor() as Number;
        } else if (min <= 10) {
            return Graphics.COLOR_YELLOW as Number;
        } else {
            return Graphics.COLOR_RED as Number;
        }
    }

    function getDeltaText(status as Dictionary) as String {
        // var status = Application.Storage.getValue("status") as Dictionary;
        if (status == null) {
            return "--";
        }
        var delta = status["delta"] as String;

        var deltaString = (delta == null) ? "--" : delta;

        return deltaString;
    }

}
