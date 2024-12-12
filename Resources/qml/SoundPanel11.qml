import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.FluentWinUI3 2.15

ApplicationWindow {
    id: window
    width: 360
    height: gridLayout.implicitHeight
    visible: false
    flags: Qt.FramelessWindowHint
    color: "transparent"

    property bool blockOutputSignal: false
    property bool blockInputSignal: false

    ListModel {
        id: appModel
    }

    function clearApplicationModel() {
        appModel.clear();
    }

    function addApplication(appID, name, isMuted, volume, icon) {
        appModel.append({
            appID: appID,
            name: name,
            isMuted: isMuted,
            volume: volume,
            icon: "data:image/png;base64," + icon
        });
    }

    function setOutputImageSource(source) {
        outputImage.source = source;
    }

    function setInputImageSource(source) {
        inputImage.source = source;
    }

    function clearPlaybackDevices() {
        outputDeviceComboBox.model.clear();
    }

    function addPlaybackDevice(deviceName) {
        outputDeviceComboBox.model.append({name: deviceName});
    }

    function clearRecordingDevices() {
        inputDeviceComboBox.model.clear();
    }

    function addRecordingDevice(deviceName) {
        inputDeviceComboBox.model.append({name: deviceName});
    }

    function setPlaybackDeviceCurrentIndex(index) {
        blockOutputSignal = true;
        outputDeviceComboBox.currentIndex = index;
        blockOutputSignal = false;
    }

    function setRecordingDeviceCurrentIndex(index) {
        blockInputSignal = true;
        inputDeviceComboBox.currentIndex = index;
        blockInputSignal = false;
    }

    Rectangle {
        anchors.fill: parent
        color: nativeWindowColor
        border.color: Qt.rgba(255, 255, 255, 0.15)
        border.width: 1
        radius: 12
    }

    GridLayout {
        id: gridLayout
        objectName: "gridLayout"
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        columns: 3
        rowSpacing: 0

        ComboBox {
            id: outputDeviceComboBox
            Layout.topMargin: 15
            Layout.bottomMargin: 10
            Layout.rightMargin: 15
            Layout.leftMargin: 15
            Layout.preferredHeight: 35
            Layout.columnSpan: 3
            Layout.fillWidth: true
            font.pixelSize: 14
            model: ListModel {}
            onCurrentTextChanged: {
                if (!window.blockOutputSignal) {
                    soundPanel.onPlaybackDeviceChanged(outputDeviceComboBox.currentText);
                }
            }
        }

        Button {
            id: outputeMuteButton
            Layout.leftMargin: 15
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            flat: true
            Layout.bottomMargin: 10
            onClicked: {
                soundPanel.onOutputMuteButtonClicked()
            }

            Image {
                id: outputImage
                width: 16
                height: 16
                anchors.margins: 0
                anchors.centerIn: parent
                source: outputIcon
                fillMode: Image.PreserveAspectFit
            }
        }

        Slider {
            id: outputSlider
            value: soundPanel.playbackVolume
            from: 0
            to: 100
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.preferredHeight: -1
            Layout.bottomMargin: 10
            Layout.leftMargin: -15
            Layout.rightMargin: 5
            onValueChanged: {
                if (pressed) {
                    soundPanel.onPlaybackVolumeChanged(value)
                }
            }

            onPressedChanged: {
                if (!pressed) {
                    soundPanel.onOutputSliderReleased()
                }
            }
        }

        Rectangle {
            id: inputSeparator
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: borderColor
            Layout.columnSpan: 3
        }

        ComboBox {
            id: inputDeviceComboBox
            Layout.topMargin: 15
            Layout.bottomMargin: 10
            Layout.rightMargin: 15
            Layout.leftMargin: 15
            Layout.preferredHeight: 35
            Layout.fillWidth: true
            Layout.columnSpan: 3
            font.pixelSize: 14
            model: ListModel {}
            onCurrentTextChanged: {
                if (!window.blockInputSignal) {
                    soundPanel.onRecordingDeviceChanged(inputDeviceComboBox.currentText);
                }
            }
        }

        Button {
            id: inputMuteButton
            Layout.leftMargin: 15
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            flat: true
            Layout.bottomMargin: 10
            onClicked: {
                soundPanel.onInputMuteButtonClicked()
            }
            Image {
                id: inputImage
                width: 16
                height: 16
                anchors.margins: 0
                anchors.centerIn: parent
                source: inputIcon
                fillMode: Image.PreserveAspectFit
            }
        }

        Slider {
            id: inputSlider
            value: soundPanel.recordingVolume
            from: 0
            to: 100
            Layout.columnSpan: 2
            Layout.fillWidth: true
            Layout.preferredHeight: -1
            Layout.bottomMargin: 10
            Layout.leftMargin: -15
            Layout.rightMargin: 5
            onValueChanged: {
                soundPanel.onRecordingVolumeChanged(value)
            }
        }

        Rectangle {
            id: appSeparator
            Layout.preferredHeight: 1
            Layout.fillWidth: true
            color: borderColor
            Layout.columnSpan: 3
            Layout.bottomMargin: 10
        }

        Label {
            text: "Volume mixer"
            Layout.leftMargin: 25
            Layout.bottomMargin: 10
            font.pixelSize: 14
            font.bold: true
            Layout.columnSpan: 3
        }

        Repeater {

            id: appRepeater
            objectName: "appRepeater"
            model: appModel
            delegate: RowLayout {
                Layout.bottomMargin: 10
                Layout.leftMargin: 15
                Layout.fillWidth: true
                Layout.columnSpan: 3

                Button {
                    id: muteButton
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    flat: true
                    checkable: true
                    checked: model.isMuted
                    onClicked: {
                        model.isMuted = !model.isMuted;
                        soundPanel.onApplicationMuteButtonClicked(model.appID, model.isMuted);
                    }

                    Image {
                        source: model.name === "Windows system sounds" ? systemSoundsIcon : model.icon
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                    }
                }

                Slider {
                    id: volumeSlider
                    from: 0
                    to: 100
                    Layout.leftMargin: -15
                    Layout.rightMargin: 5
                    value: model.volume
                    Layout.fillWidth: true
                    onValueChanged: {
                        soundPanel.onApplicationVolumeSliderValueChanged(model.appID, value);
                        //modelData.volume = value; // Update the model
                    }
                }
            }
        }
    }
}
