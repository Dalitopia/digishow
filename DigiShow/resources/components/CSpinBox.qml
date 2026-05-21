import QtQuick 2.12
import QtQuick.Controls 2.12

SpinBox {

    id: spinBox

    property string unit: ""

    width: 100
    height: 28
    editable: true
    font.pixelSize: 12
    focus: false
    value: 0

    onValueChanged: syncEditorText()

    function syncEditorText() {
        if (!editor) return // ignore if editor is not initialized
        editor.text = spinBox.textFromValue(spinBox.value)
    }

    function commitEditorText() {
        if (!editor) return // ignore if editor is not initialized
        spinBox.value = spinBox.valueFromText(editor.text)
        valueModified() // emit signal
        syncEditorText()
    }

    background: Rectangle {
        color: "#181818"
        border.color: "#383838"
        border.width: 1
        radius: 3
    }

    contentItem: Item {

        anchors.fill: parent
        anchors.leftMargin: spinBox.height
        anchors.rightMargin: spinBox.height

        Text {
            id: unitText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: spinBox.unit
            font: spinBox.font
            color: "#cccccc"
            visible: spinBox.unit !== ""
        }

        TextInput {
            id: editor

            anchors.left: parent.left
            anchors.right: unitText.visible ? unitText.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            font: spinBox.font
            color: "#cccccc"
            selectionColor: "#666666"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            selectByMouse: true
            readOnly: !spinBox.editable
            validator: spinBox.validator
            inputMethodHints: Qt.ImhDigitsOnly
            clip: true

            Component.onCompleted: spinBox.syncEditorText()

            onActiveFocusChanged: {
                if (!activeFocus)
                    spinBox.commitEditorText()
            }

            Keys.onReturnPressed: {
                spinBox.commitEditorText()
                editor.focus = false
                spinBox.focus = false
                event.accepted = true
            }

            Keys.onEnterPressed: {
                spinBox.commitEditorText()
                editor.focus = false
                spinBox.focus = false
                event.accepted = true
            }

            onEditingFinished: {
                spinBox.commitEditorText()
                editor.focus = false
                spinBox.focus = false
            }
        }
    }

    textFromValue: function(value) {
        return value.toString()
    }

    valueFromText: function(text) {
        var val = parseInt(text, 10)
        if (isNaN(val))
            val = spinBox.value
        val = Math.min(spinBox.to, val)
        val = Math.max(spinBox.from, val)
        return val
    }
}
