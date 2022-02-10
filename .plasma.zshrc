fix-taskmanager () {
    sudo sd \
        'value: \(tasksModel\.anyTaskDemandsAttention\n.*' \
        'value: (PlasmaCore.Types.PassiveStatus)' \
        /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/ui/main.qml
}

fix-tg-icons () {
    local size
    for size in 16 22 24; do
        # sed \
            # 's/ColorScheme-Highlight/ColorScheme-ButtonText/g' \
            # /usr/share/icons/Tela/$size/panel/telegram-attention-panel.svg \
        # >~/.local/share/icons/Tela/$size/panel/telegram-attention-panel.svg
        sd \
            'ColorScheme-Highlight' \
            'ColorScheme-ButtonText' \
            </usr/share/icons/Tela/$size/panel/telegram-attention-panel.svg \
        >~/.local/share/icons/Tela/$size/panel/telegram-attention-panel.svg
        sd \
            'class="ColorScheme-Text"' \
            'class="ColorScheme-ButtonText"' \
            ~/.local/share/icons/Tela/$size/panel/telegram-attention-panel.svg
    done

}

# mk-kcm-launchers () {
#
# }
