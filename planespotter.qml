/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.4
import QtQuick.Window 2.2
import QtPositioning 5.5
import QtLocation 5.6

Window {
    width: 700
    height: 500
    visible: true

    property variant topLeftEurope: QtPositioning.coordinate(60.5, 0.0)
    property variant bottomRightEurope: QtPositioning.coordinate(51.0, 14.0)
    property variant viewOfEurope:
            QtPositioning.rectangle(topLeftEurope, bottomRightEurope)

    property variant berlin: QtPositioning.coordinate(52.5175, 13.384)
    property variant oslo: QtPositioning.coordinate(59.9154, 10.7425)
    property variant london: QtPositioning.coordinate(51.5, 0.1275)
    property variant point1: QtPositioning.coordinate(53.5175, 14.384)
    property variant point2: QtPositioning.coordinate(60.9154, 11.7425)
    property variant point3: QtPositioning.coordinate(50.358157, 26.697923)
    property variant shepetivka: QtPositioning.coordinate(50.181360, 27.053639)
    property variant kyiv: QtPositioning.coordinate(50.464055, 30.498494)



    Map {
        id: mapOfEurope
        anchors.centerIn: parent;
        anchors.fill: parent
        plugin: Plugin {
            name: "osm" // "mapboxgl", "esri", ...
        }

        Plane {
            id: qmlPlane
            pilotName: "QML"
            coordinate: oslo2Berlin.position

            SequentialAnimation {
                id: qmlPlaneAnimation
                property real rotationDirection : 0;
                NumberAnimation {
                    target: qmlPlane; property: "bearing"; duration: 1000
                    easing.type: Easing.InOutQuad
                    to: qmlPlaneAnimation.rotationDirection
                }
                //! [QmlPlane1]
                CoordinateAnimation {
                    id: coordinateAnimation; duration: 5000
                    target: oslo2Berlin; property: "position"
                    easing.type: Easing.InOutQuad
                }
                //! [QmlPlane1]

                onStopped: {
                    if (coordinateAnimation.to === berlin)
                        qmlPlane.showMessage(qsTr("Hello Berlin!"))
                    else if (coordinateAnimation.to === oslo)
                        qmlPlane.showMessage(qsTr("Hello Oslo!"))
                }
                onStarted: {
                    if (coordinateAnimation.from === oslo)
                        qmlPlane.showMessage(qsTr("See you Oslo!"))
                    else if (coordinateAnimation.from === berlin)
                        qmlPlane.showMessage(qsTr("See you Berlin!"))
                }
            }

            //! [QmlPlane2]
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (qmlPlaneAnimation.running) {
                        console.log("Plane still in the air.");
                        return;
                    }

                    if (oslo2Berlin.position === berlin) {
                        coordinateAnimation.from = berlin;
                        coordinateAnimation.to = oslo;
                    } else if (oslo2Berlin.position === oslo) {
                        coordinateAnimation.from = oslo;
                        coordinateAnimation.to = berlin;
                    }

                    qmlPlaneAnimation.rotationDirection = oslo2Berlin.position.azimuthTo(coordinateAnimation.to)
                    qmlPlaneAnimation.start()
                }
            }
            //! [QmlPlane2]
            Component.onCompleted: {
                oslo2Berlin.position = oslo;
            }
        }

        //! [CppPlane1]
        Plane {
            id: cppPlane
            pilotName: "C++"
            coordinate: berlin2London.position

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (cppPlaneAnimation.running || berlin2London.isFlying()) {
                        console.log("Plane still in the air.");
                        return;
                    }

                    berlin2London.swapDestinations();
                    cppPlaneAnimation.rotationDirection = berlin2London.position.azimuthTo(berlin2London.to)
                    cppPlaneAnimation.start();
                    cppPlane.departed();
                }
            }
        //! [CppPlane1]
            //! [CppPlane3]
            SequentialAnimation {
                id: cppPlaneAnimation
                property real rotationDirection : 0;
                NumberAnimation {
                    target: cppPlane; property: "bearing"; duration: 1000
                    easing.type: Easing.InOutQuad
                    to: cppPlaneAnimation.rotationDirection
                }
                ScriptAction { script: berlin2London.startFlight() }
            }
            //! [CppPlane3]

            Component.onCompleted: {
                berlin2London.position = berlin;
                berlin2London.to = london;
                berlin2London.from = berlin;
                berlin2London.arrived.connect(arrived)
            }

            function arrived(){
                if (berlin2London.to === berlin)
                    cppPlane.showMessage(qsTr("Hello Berlin!"))
                else if (berlin2London.to === london)
                    cppPlane.showMessage(qsTr("Hello London!"))
            }

            function departed(){
                if (berlin2London.from === berlin)
                    cppPlane.showMessage(qsTr("See you Berlin!"))
                else if (berlin2London.from === london)
                    cppPlane.showMessage(qsTr("See you London!"))
            }
        //! [CppPlane2]
        }
        //! [CppPlane2]
        Plane {
            id: myPlane
            pilotName: "my own plane"
            coordinate: myPlaneControl.position

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (myPlaneAnimation.running || myPlaneControl.isFlying()) {
                        console.log("Plane still in the air.");
                        return;
                    }

                    //myPlaneControl.swapDestinations(); feature

                    //set variable
                    myPlaneAnimation.rotationDirection = myPlaneControl.position.azimuthTo(myPlaneControl.to)

                    //it calls startFlight in the controller
                    myPlaneAnimation.start(); // move the plane
                    myPlane.departed(); // show messages


                }
            }
        //! [CppPlane1]
            //! [CppPlane3]
            SequentialAnimation {
                id: myPlaneAnimation
                property real rotationDirection : 0;

                NumberAnimation {
                    // Rotation to next point
                    /*
                    target: myPlane; property: "bearing"; duration: 1000
                    easing.type: Easing.InOutQuad
                    to: myPlaneAnimation.rotationDirection*/
                }
                // called when "myPlaneAnimation.start()"
                ScriptAction { script: myPlaneControl.startFlight() }
            }
            //! [CppPlane3]

            // when qml is loaded
            Component.onCompleted: {
                myPlaneControl.position = london;  // default position before moving
                myPlaneControl.from = point1;  // start position
                myPlaneControl.to = point2;  // end position
                myPlaneControl.arrived.connect(arrived)
            }

            function arrived(){
                if (myPlaneControl.to === point2)
                    myPlane.showMessage(qsTr("Hello Mthfck!"))
                else if (myPlaneControl.to === point1)
                    myPlane.showMessage(qsTr("Hello b*tches!"))
            }

            function departed(){
                if (myPlaneControl.from === point2)
                    myPlane.showMessage(qsTr("See you bro!"))
                else if (myPlaneControl.from === point1)
                    myPlane.showMessage(qsTr("Bye, see you soon!"))
            }
        //! [CppPlane2]
            //! [CppPlane1]
                //! [CppPlane3]
 /*           SequentialAnimation {
                id: myPlaneAnimation2
                property real rotationDirection : 0;
                NumberAnimation {
                    target: myPlane; property: "bearing"; duration: 1000
                    easing.type: Easing.InOutQuad
                    to: myPlaneAnimation2.rotationDirection
                }
                ScriptAction { script: myPlaneControl.startFlight() }
            }*/
            //! [CppPlane3]
/*
            Component.onCompleted: {
                myPlaneControl.position = point2;
                myPlaneControl.to = point3;
                myPlaneControl.from =point2 ;
                myPlaneControl.arrived.connect(arrived)
            }*/

        }

        visibleRegion: viewOfEurope
    }

    Rectangle {
        id: infoBox
        anchors.centerIn: parent
        color: "white"
        border.width: 1
        width: text.width * 1.3
        height: text.height * 1.3
        radius: 5
        Text {
            id: text
            anchors.centerIn: parent
            text: qsTr("Hit the plane to start the flight!")
        }

        Timer {
            interval: 5000; running: true; repeat: false;
            onTriggered: fadeOut.start()
        }

        NumberAnimation {
            id: fadeOut; target: infoBox;
            property: "opacity";
            to: 0.0;
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }
}
