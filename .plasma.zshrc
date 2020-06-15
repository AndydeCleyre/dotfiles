fix-taskmanager () {
    sudo sd \
        'value: \(tasksModel\.anyTaskDemandsAttention\n.*' \
        'value: (PlasmaCore.Types.PassiveStatus)' \
        /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/ui/main.qml
}
