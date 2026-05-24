import QtQuick 2.12
import QtQuick.Controls 2.12

SpinBox {

    id: doubleSpinBox

    property string unit: ""
    property int decimals: 1
    property real realFrom: 0.0
    property real realTo: 100.0
    property real realStepSize: 1.0
    property real realValue: 0.0

    readonly property int effectiveDecimals: Math.max(0, decimals)
    // SpinBox works with integers, so float values are stored as scaled integers.
    readonly property int scaleFactor: Math.round(Math.pow(10, effectiveDecimals))
    property bool syncingValue: false

    signal valueModified()

    width: 100
    height: 28
    editable: true
    font.pixelSize: 12
    focus: false

    from: scaledValue(realFrom)
    to: scaledValue(realTo)
    stepSize: Math.max(1, Math.abs(scaledValue(realStepSize)))
    validator: DoubleValidator {
        bottom: Math.min(doubleSpinBox.realFrom, doubleSpinBox.realTo)
        top: Math.max(doubleSpinBox.realFrom, doubleSpinBox.realTo)
        decimals: doubleSpinBox.effectiveDecimals
        notation: DoubleValidator.StandardNotation
    }

    onValueChanged: {
        syncRealValueFromInt()
        syncEditorText()
    }
    onRealValueChanged: syncIntValueFromReal()
    onRealFromChanged: syncIntValueFromReal()
    onRealToChanged: syncIntValueFromReal()
    onRealStepSizeChanged: syncEditorText()
    onDecimalsChanged: syncIntValueFromReal()

    Component.onCompleted: syncIntValueFromReal()

    function scaledValue(realNumber) {
        return Math.round(realNumber * scaleFactor)
    }

    function normalizeRealValue(realNumber) {
        var fallbackValue = value / scaleFactor
        if (isNaN(realNumber))
            realNumber = fallbackValue

        var minimum = Math.min(realFrom, realTo)
        var maximum = Math.max(realFrom, realTo)
        var clampedValue = Math.min(maximum, Math.max(minimum, realNumber))
        return Number(clampedValue.toFixed(effectiveDecimals))
    }

    function syncRealValueFromInt() {
        if (syncingValue)
            return

        var normalizedValue = normalizeRealValue(value / scaleFactor)
        syncingValue = true
        realValue = normalizedValue
        var scaledIntValue = scaledValue(normalizedValue)
        if (value !== scaledIntValue)
            value = scaledIntValue
        syncingValue = false
    }

    function syncIntValueFromReal() {
        if (syncingValue)
            return

        var normalizedValue = normalizeRealValue(realValue)
        var scaledIntValue = scaledValue(normalizedValue)
        syncingValue = true
        if (realValue !== normalizedValue)
            realValue = normalizedValue
        if (value !== scaledIntValue)
            value = scaledIntValue
        syncingValue = false
        syncEditorText()
    }

    function syncEditorText() {
        if (!editor)
            return
        editor.text = textFromValue(value)
    }

    function commitEditorText() {
        if (!editor)
            return
        value = valueFromText(editor.text)
        syncEditorText()
        valueModified() // emit signal
    }

    background: Rectangle {
        color: "#181818"
        border.color: "#383838"
        border.width: 1
        radius: 3
    }

    contentItem: Item {

        anchors.fill: parent
        anchors.leftMargin: doubleSpinBox.height
        anchors.rightMargin: doubleSpinBox.height

        Text {
            id: unitText
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: doubleSpinBox.unit
            font: doubleSpinBox.font
            color: "#cccccc"
            visible: doubleSpinBox.unit !== ""
        }

        TextInput {
            id: editor

            anchors.left: parent.left
            anchors.right: unitText.visible ? unitText.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            font: doubleSpinBox.font
            color: "#cccccc"
            selectionColor: "#666666"
            selectedTextColor: "#ffffff"
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            selectByMouse: true
            readOnly: !doubleSpinBox.editable
            validator: doubleSpinBox.validator
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            clip: true

            Component.onCompleted: doubleSpinBox.syncEditorText()

            onActiveFocusChanged: {
                if (!activeFocus)
                    doubleSpinBox.commitEditorText()
            }

            Keys.onReturnPressed: {
                doubleSpinBox.commitEditorText()
                editor.focus = false
                doubleSpinBox.focus = false
                event.accepted = true
            }

            Keys.onEnterPressed: {
                doubleSpinBox.commitEditorText()
                editor.focus = false
                doubleSpinBox.focus = false
                event.accepted = true
            }

            onEditingFinished: {
                doubleSpinBox.commitEditorText()
                editor.focus = false
                doubleSpinBox.focus = false
            }
        }
    }

    textFromValue: function(value) {
        return (value / scaleFactor).toFixed(effectiveDecimals)
    }

    valueFromText: function(text) {
        var parsedValue = parseFloat(text)
        var normalizedValue = normalizeRealValue(parsedValue)
        return scaledValue(normalizedValue)
    }
}
