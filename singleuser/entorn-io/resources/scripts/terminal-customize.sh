#!/bin/bash

PYTHON_VERSION_MAJOR=3.11

TERMINAL_JS_CONFIG_FILE=${CONDA_BASE_PATH}/lib/python${PYTHON_VERSION_MAJOR}/site-packages/notebook/static/terminal/js/main.min.js && \
	sed -i "s/DEFAULT_BACKGROUND = '#000000'/DEFAULT_BACKGROUND = '#FAF5EF'/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/DEFAULT_FOREGROUND = '#ffffff'/DEFAULT_FOREGROUND = '#000000'/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/DEFAULT_CURSOR = '#ffffff'/DEFAULT_CURSOR = '#000000'/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/DEFAULT_CURSOR_ACCENT = '#000000'/DEFAULT_CURSOR_ACCENT = '#ffffff'/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/rgba(255, 255, 255, 0.3)/rgba(155, 5, 155, 0.3)/g" $TERMINAL_JS_CONFIG_FILE
sed -i "s/courier-new, courier/lucidatypewriter/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/fontSize: 15/fontSize: 18/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/letterSpacing: 0/letterSpacing: 0.1/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/lineHeight: 1.0/lineHeight: 1.1/g" $TERMINAL_JS_CONFIG_FILE && \
	sed -i "s/cursorBlink: false/cursorBlink: true/g" $TERMINAL_JS_CONFIG_FILE
echo "Customization for Classic Notebook Terminal done!"
exit 0


