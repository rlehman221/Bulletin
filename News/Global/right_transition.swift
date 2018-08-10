/**
 * right_transition
 *
 * Created on: July 8, 2018
 * Authors: Ryan Lehman
 *
 * Description: A custom seque for pushing the screen to the right. Can be
 * set on the storyboard
 */

import UIKit

class UIStoryboardSegueFromRight: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                       },
                       completion: { finished in
                            src.present(dst, animated: false, completion: nil)
                       }
        )
    }
}

class UIStoryboardUnwindSegueFromRight: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, belowSubview: src.view)
        src.view.transform = CGAffineTransform(translationX: 0,y: 0)
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        src.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        },
                       completion: { finished in
                        src.dismiss(animated: false, completion: nil)
        }
        )
    }
}
