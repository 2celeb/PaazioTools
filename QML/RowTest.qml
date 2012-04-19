import QtQuick 1.1

/**
 * Row organises its child items to a row
 * http://doc.qt.nokia.com/4.7/qml-row.html
 */
Rectangle {
	width: 800
	height: 600

	Component.onCompleted: {
		for (var i = 0; i < 50; ++i) {
			var item = Qt.createQmlObject('; Rectangle {}',
				positioner, "item" + i);
            item.color = Qt.rgba(Math.random(), Math.random(), Math.random(), 1);
            item.width = Math.random() * 30 + 10;
            item.height = Math.random() * positioner.height / 2 + 10;
		}
	}

	Row {
		id: positioner
		anchors.fill: parent
		spacing: 2
		add: Transition {
			NumberAnimation {
				properties: "x"
				easing.type: Easing.OutBounce
			}
		}
		move: Transition {
			NumberAnimation {
				properties: "x"
				easing.type: Easing.OutBounce
			}
		}
	}
}
