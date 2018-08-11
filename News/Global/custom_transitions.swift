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
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        src.view.window?.layer.add(transition, forKey: nil)
        src.present(dst, animated: false, completion: nil)
    }
}

class UIStoryboardSegueFromLeft: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.25
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        src.view.window?.layer.add(transition, forKey: nil)
        src.present(dst, animated: false, completion: nil)
    }
}
