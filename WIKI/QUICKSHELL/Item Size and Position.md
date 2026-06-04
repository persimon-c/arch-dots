Item Size and Position
TIP

Read the entire page, as understanding this is critical to building a well designed shell.

An Item (and its subclasses) has two sets of size properties:

actual size (Item.width and Item.height)
implicit/desired size (Item.implicitWidth and Item.implicitHeight)
Container items, such as layouts and wrappers, use the implicit size of their children to determine their own implicit size. They use their actual size to determine the sizes of their children.

If an Item is managed by a container, it should not set its own size. Instead, it should allow the container to determine its size based on its implicit size.

In other words, implicit size should flow from children to parent, while actual size should flow from parent to children.

In addition to size, Items also have positional properties (Item.x and Item.y). Similar to actual size, the actual position should not be set directly if the item is managed by a container, though there is no such thing as implicit position.

WARNING

Many QtQuick Items have zero size by default (both implicit and actual).

An invisible, zero-sized item, which is usually a custom container without implicit size set, is a common bug and often manifests as an item being laid out as if it took no space.

Quickshell will attempt to detect zero-sized items when a window is initially made visible and log a warning, but it cannot detect all cases. Please be aware that these exist.

Container Items
Below is an example container that adds a margin to its child rectangle and interacts properly with other container types.

Item {
  property real margin: 5

  // Set the implicit size of the containing item to the size of
  // the contained item, plus the margin on each side.
  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  Rectangle {
    id: child

    // Set the size of the child item relative to the actual size
    // of the parent item. If the parent item is constrained
    // or stretched the child's position and size will be similarly
    // constrained.
    x: parent.margin
    y: parent.margin
    width: parent.width - parent.margin * 2
    height: parent.height - parent.margin * 2

    // The child's implicit / desired size, which will be respected
    // by the container item as long as it is not constrained
    // or stretched.
    implicitWidth: 50
    implicitHeight: 50
  }
}
If we were to write this as a reusable component, we could use Binding to control the child item’s actual size and position.

Item {
  id: wrapper
  property real margin: 5
  required default property Item child

  // Set the item's visual children list to just the passed item.
  children: [child]

  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  // Bind the child's position and size.
  // Note that this syntax is exclusive to the Binding type.
  Binding { wrapper.child.x: wrapper.margin }
  Binding { wrapper.child.y: wrapper.margin }
  Binding { wrapper.child.width: wrapper.width - wrapper.margin * 2 }
  Binding { wrapper.child.height: wrapper.height - wrapper.margin * 2 }
}
TIP

Quickshell has a built-in component WrapperItem that adds margins similar to the behavior above.

Reducing boilerplate with Anchors
We can reduce the amount of boilerplate we have to write using QtQuick Anchors.

Anchors exist as a shorthand way to achieve many common position and size bindings. See the linked qt documentation for more details on how to use them.

The following example is equivalent to the one above, but uses anchors instead of setting position and size directly. A similar change can be made to the Binding example.

Item {
  property real margin: 5

  implicitWidth: child.implicitWidth + margin * 2
  implicitHeight: child.implicitHeight + margin * 2

  Rectangle {
    id: child

    // "Fill" the space occupied by the parent, setting width
    anchors.fill: parent
    // Add a margin to all anchored sides.
    anchors.margins: parent.margin

    implicitWidth: 50
    implicitHeight: 50
  }
}
childrenRect and binding loops
The most common mistake made when creating container items is trying to use Item.childrenRect to determine the size of a child item, such as in the example below:

Item {
  implicitWidth: childrenRect.width
  implicitHeight: childrenRect.height

  Rectangle {
    anchors.fill: parent

    implicitWidth: 50
    implicitHeight: 50
  }
}
While the snippet above might look like it should work, it is actually hiding a nasty bug.

As stated at the top of the page, an item’s implicit size should be used to determine its parent’s implicit size, and the parent’s actual size should be used to determine the child’s actual size. The childrenRect breaks this pattern.

The childrenRect property represents the actual geometry of all child items, not their implicit geometry. This results in the container item’s size having an indirect dependency on itself, which is known as a binding loop.

If we were to try to figure out what implicitWidth is by hand, it would look something like this:

container.implicitWidth = container.childrenRect.width = child.width = container.width (via anchor) = container.implicitWidth = … (repeats forever)

which isn’t a valid definition.

MarginWrapper components
To solve the boilerplate problem, which often leads users to use childrenRect, Quickshell comes with MarginWrapperManager and a set of components based on it.

MarginWrapperManager automatically handles the size and position relationship between a container item and a single child item, skipping most of the boilerplate in the above examples. See its linked documentation for more information on how to use it.

Rewriting the examples from the top of the page:

Item {
  MarginWrapperManager { margin: 5 }

  // Automatically detected by MarginWrapperManager as the
  // primary child of the container and sized accordingly.
  Rectangle {
    implicitWidth: 50
    implicitHeight: 50
  }
}
Or as a reusable component:

Item {
  // A bidirectional binding to manager.margin,
  // where the default value is set.
  property alias margin: manager.margin

  // MarginWrapperManager tries to automatically detect
  // the primary child of the container, but exposing the
  // child property allows us to both access the child
  // externally and override it if automatic detection fails.
  property alias child: manager.margin

  // MarginWrapperManager automatically manages the implicit size
  // of the container and actual size of the child.
  MarginWrapperManager {
    id: manager
    margin: 5 // the default value of margin
  }
}
Quickshell bundles three of the most commonly used wrappers, which are implemented similarly to the example above:

WrapperItem
WrapperRectangle
WrapperMouseArea
Layouts
QtQuick comes with a set of layout types in the QtQuick.Layouts module.

Layouts, such as the Row, Column, and Grid layout, are extremely useful for positioning items adjacent to each other. See the linked Qt documentation for more details.

NOTE

Layouts have a default spacing of 5 pixels between items, not zero.
Items in a Layout will be pixel-aligned.
Layouts vs. Row and Column
In addition to the RowLayout and ColumnLayout types, QtQuick has similarly named Row and Column types.

The Layout types are generally much more flexible and enable the usage of the Layout attached object.

In contrast, the Row and Column types are not part of Qt’s Layout system and do not have access to the Layout attached object. In addition, Row and Column do not pixel-align members, meaning if you have a member with a fractional size, it will break the pixel alignment of members following it.

In general, RowLayout and ColumnLayout should be used over Row and Column outside of cases where pixel alignment is intentionally broken.