//
//  FontPicker.swift
//  FontPicker
//
//  Created by Samantha Todd on 7/9/17.
//  Copyright © 2017 Samantha Todd. All rights reserved.
//

import UIKit

@objc public protocol FontPickerDelegate: class {
    @objc optional func fontPicker(_ fontPicker: FontPicker, didSelect font: String)
    @objc optional func fontPicker(_ fontPicker: FontPicker, didDismissWith font: String)
}

open class FontPicker: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    /**
     Object that responds to font selections.
     */
    public weak var fontPickerDelegate: FontPickerDelegate?
    

    /**
     Color of the toolbar's buttons.
     */
    public var barTintColor = UIColor.blue
    
    /**
     Color of the checkmark that appears on the selected font.
     */
    public var selectionTintColor = UIColor.blue
    
    /**
     If true, the area above the picker will be shaded in semi-transparent gray.
     */
    public var dimsBackground = false
    
    /**
     Font that should initially appear selected (i.e. the current font of the presenting view's focused text input field.
     */
    public var initialFontName: String?
    
    /**
     If true, the picker will use the entire screen. If false, the picker will appear similar to the keyboard.
     */
    public var fullscreen = false
    
    /**
     Background color of the toolbar.
     */
    public var barBackgroundColor = UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
    
    private var fonts = UIFont.familyNames.sorted()
    private var tableView: UITableView!
    private var backgroundView: UIView?

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        if dimsBackground && !fullscreen, let vc = presentingViewController {
            backgroundView = UIView(frame: vc.view.frame)
            backgroundView?.backgroundColor = UIColor.clear
            vc.view.addSubview(self.backgroundView!)
        }
        
        view.backgroundColor = UIColor.clear
        
        tableView = UITableView()
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: tableView, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        if !fullscreen {
            NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 0.35, constant: 0).isActive = true
        }
        
        let toolbar = UIToolbar()
        toolbar.tintColor = barTintColor
        toolbar.isTranslucent = false
        toolbar.barTintColor = barBackgroundColor
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbar)
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: toolbar, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: toolbar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50).isActive = true
        if fullscreen {
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1, constant: 0).isActive = true
        }
        
        // Hairline bottom border for toolbar
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor.lightGray
        view.addSubview(border)
        NSLayoutConstraint(item: border, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: border, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: border, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: border, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0.5).isActive = true
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissFontPicker))
        toolbar.items = [flexItem, doneItem]
        
        // Tap outside to dismiss
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissFontPicker))
        tapGestureRecognizer.delegate = self
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if dimsBackground && !fullscreen {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            })
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if dimsBackground && !fullscreen {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.backgroundColor = UIColor.clear
            }) { (animted) in
                self.backgroundView?.removeFromSuperview()
            }
        }
    }
    
    // MARK: - Table view data source

    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return fonts.count
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let fontName = fonts[indexPath.row]
        cell.selectionStyle = .none
        if fontName == initialFontName {
            cell.isSelected = true
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            initialFontName = nil
        }
        if cell.isSelected {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        cell.textLabel?.font = UIFont(name: fontName, size: 17)
        cell.textLabel?.text = fontName
        cell.tintColor = selectionTintColor
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        fontPickerDelegate?.fontPicker?(self, didSelect: fonts[indexPath.row])
    }
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
    func dismissFontPicker() {
        var selectedFont: String?
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            selectedFont = fonts[selectedIndexPath.row]
        }
        if dimsBackground {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.backgroundColor = UIColor.clear
            })
        }
        dismiss(animated: true) {
            if let font = selectedFont {
                self.fontPickerDelegate?.fontPicker?(self, didDismissWith: font)
            }
        }
    }
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view != view {
            return false
        }
        return true
    }

}
