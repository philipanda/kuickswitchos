import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami as Kirigami


PlasmoidItem {
    id: root
    property string selectedBootnum: ""
    
    preferredRepresentation: compactRepresentation

    // Contains the bootentries for this system
    ListModel {
        id: itemsModel
        ListElement { bootnum: "0000-example"; osname: "Failed to retrieve the bootorder" }
    }

    Component.onCompleted: {
        parse_bootorder()
    }

    // Panel bar icon
    compactRepresentation: Item {
        PlasmaComponents.ToolButton {
            icon.name: Plasmoid.icon
            onClicked: {
                root.expanded = !root.expanded
            }
        }
    }

    // Main plasmoid panel
    fullRepresentation: ColumnLayout {
        id: column
        spacing: Kirigami.Units.gridUnit
        // A title
        Kirigami.Heading {
            id: header
            text: i18n("Switch OS")
        }

        // List of OSes
        Kirigami.AbstractCard {
            contentItem: ListView {
                id: listView
                implicitHeight: contentItem.childrenRect.height
                Layout.fillWidth: true
                model: itemsModel

                // Will contain rows for each OS
                delegate: RowLayout {
                    anchors.right: parent.right
                    anchors.left: parent.left
                    height: Kirigami.Units.gridUnit * 1.5

                    // OS name
                    PlasmaComponents.Label {
                        id: label
                        Layout.fillWidth: true
                        text: model.osname

                    }

                    // Radio button to select an OS to boot
                    PlasmaComponents.RadioButton {
                        id: radioBtn
                        ButtonGroup.group: radioGroup
                        onClicked: {
                            console.log("Button clicked for:", model.osname)
                            console.log("Booting:", model.bootnum)
                            root.selectedBootnum = model.bootnum
                        }
                    }
                }

                // Needed to group the radios into a group so that only one can be checked
                ButtonGroup {
                    id: radioGroup
                }
            }
        }

        // Button to set nextboot and reboot system to boot the selected OS
        PlasmaComponents.Button {
            Layout.fillWidth: true
            text: i18n("Apply & Reboot")
            onClicked: {
                applyAndReboot()
            }
        }
    }

    // Parser for efibootmgr bootorder
    Plasma5Support.DataSource {
        id: bootorderSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            
            if (data["exit code"] === 0 && data["stdout"]) {
                itemsModel.clear()
                const lines = data["stdout"].split("\n")
                lines.forEach(function(line) {
                if (line.trim() !== "") {
                    const items = line.trim().split(" ")
                    console.log(items)
                    itemsModel.append({ bootnum: items[0], osname: items[1] })
                }
            })
            } else {
                console.log("Command failed:", data["stderr"])
            }
        }
    }

    // Parser for applying nextboot and rebooting
    Plasma5Support.DataSource {
        id: setNextbootSource
        engine: "executable"
        connectedSources: []

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
            
            if (data["exit code"] === 0 && data["stdout"]) {
                console.log(`Rebooting to ${selectedBootnum}`)
            } else {
                console.log("Command failed:", data["stderr"])
            }
        }
    }

    function parse_bootorder() {
        bootorderSource.connectSource('bash -c "efibootmgr | awk \'/^Boot[0-9]/ {gsub(/Boot|\\*/,\\"\\",\\$1); print \\$1, \\$2}\'"')
    }

    function applyAndReboot() {
        setNextbootSource.connectSource(`bash -c "pkexec efibootmgr --bootnext ${root.selectedBootnum} && qdbus6 org.kde.LogoutPrompt /LogoutPrompt promptReboot"`)
    }
    
}