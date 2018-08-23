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
        dst.view.transform = CGAffineTransform(translationX: (src.view.frame.size.width)*2, y: 0)
        print(src)
        print(dst)
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                       }, completion: { finished in
                            src.present(dst, animated: false, completion: nil)
                       }
        )
    }
}

class UIStoryboardSegueLogin_To_Feed: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as! UITabBarController
        dst.selectedViewController = dst.viewControllers?[0]
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: (src.view.frame.size.width)*2, y: 0)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finished in
            src.present(dst, animated: false, completion: nil)
        }
        )
    }
}

class UIStoryboardSegueFrom_MenuItem_To_Menu_Left: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as! UITabBarController
        dst.selectedViewController = dst.viewControllers?[2]
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.2
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        src.view.window?.layer.add(transition, forKey: nil)
        
        src.present(dst, animated: false, completion: nil)
    }
}

class UIStoryboardSegueFrom_Post_To_MyFeed_Left: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as! UITabBarController
        dst.selectedViewController = dst.viewControllers?[1]
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.2
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        src.view.window?.layer.add(transition, forKey: nil)
        src.present(dst, animated: false, completion: nil)
    }
}

class UIStoryboardSegueFrom_Post_To_AllFeed_Left: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as! UITabBarController
        print(dst)
        dst.selectedViewController = dst.viewControllers?[0]
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.2
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        src.view.window?.layer.add(transition, forKey: nil)
        src.present(dst, animated: false, completion: nil)
    }
}

class UIStoryboardSegueNormalLeft: UIStoryboardSegue
{
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        let transition: CATransition = CATransition()
        let timeFunc: CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.2
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        src.view.window?.layer.add(transition, forKey: nil)
        src.present(dst, animated: false, completion: nil)
    }
}
