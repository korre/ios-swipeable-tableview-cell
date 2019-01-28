# Swipeable table view cell for iOS
![](https://media.giphy.com/media/cRMhd8NacKpGJ3qF54/giphy.gif)

Swipeable table view cell that might hide some actions or a custom view of your choosing.
Simple class to extend with your table view cell to get "swipe to reveal" functionality and with the ability to have any `UIView` as a back side view.

## How to use

Extend the `SwipeableTableViewCell` found in the Cell package.
```
class TableViewCell: SwipeableTableViewCell
```

Setup and add a view representing the back side of the cell.
```
let view = BackSideView(frame: .zero)
       
let button = UIButton()
// Setup your child views here
        
view.contentView.addSubview(button)
        
button.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor).isActive = true
button.topAnchor.constraint(equalTo: view.contentView.topAnchor).isActive = true
button.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor).isActive = true
button.leadingAnchor.constraint(equalTo: button2.trailingAnchor) .isActive = true

self.backSideView = view
```

Now you should be all setup and the swipe to reveal should work.
<br><br>
*NB. The back view needs to be able to measure its width for the SwipeableTableViewCell to be able to lay it out properly. So don't forget to set all the contraints needed to obtain the width.*

## Example code
Example code is provided. Checkout the code and run the project on a device or simulator.
