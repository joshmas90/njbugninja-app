import UIKit
import UserNotifications

@main
final class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?
    private weak var launchOverlay: NinjaLaunchOverlay?
    private var hasStartedLaunchOverlay = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor(red: 0.008, green: 0.016, blue: 0.012, alpha: 1)
        window.rootViewController = RootTabBarController()
        window.tintColor = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
        let launchOverlay = NinjaLaunchOverlay(frame: window.bounds)
        launchOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(launchOverlay)
        self.launchOverlay = launchOverlay
        self.window = window
        window.makeKeyAndVisible()
        window.bringSubviewToFront(launchOverlay)

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        guard
            !hasStartedLaunchOverlay,
            let window = window,
            let launchOverlay = launchOverlay
        else {
            return
        }

        window.bringSubviewToFront(launchOverlay)

        // Start Core Animation only after iOS marks the app active. Starting it
        // during didFinishLaunching can let the sequence advance off-screen,
        // especially when the system prewarms the process before the user opens it.
        DispatchQueue.main.async { [weak self, weak window, weak launchOverlay] in
            guard
                let self = self,
                !self.hasStartedLaunchOverlay,
                application.applicationState == .active,
                let window = window,
                !window.isHidden,
                let launchOverlay = launchOverlay,
                launchOverlay.window === window
            else {
                return
            }

            // A launch interrupted before this callback must remain eligible
            // to play when the app next becomes active.
            self.hasStartedLaunchOverlay = true
            window.layoutIfNeeded()
            window.bringSubviewToFront(launchOverlay)
            launchOverlay.play()
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) { completionHandler([.banner, .list, .sound]) }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) { DispatchQueue.main.async { [weak self] in (self?.window?.rootViewController as? RootTabBarController)?.showAppointments(); completionHandler() } }
}

private final class NinjaLaunchOverlay: UIView {
    private enum Palette {
        static let background = UIColor(red: 0.008, green: 0.016, blue: 0.012, alpha: 1)
        static let red = UIColor(red: 0.878, green: 0.125, blue: 0.153, alpha: 1)
        static let green = UIColor(red: 0.561, green: 0.741, blue: 0.180, alpha: 1)
    }
    private let stage=UIView(), redHaze=CAGradientLayer(), greenHaze=CAGradientLayer(), aura=CAShapeLayer(), burst=CAShapeLayer(), orbit=CAShapeLayer(), redOrb=CAShapeLayer(), greenOrb=CAShapeLayer(), strikeGlow=CAShapeLayer(), strike=CAShapeLayer(), strikeTip=CAShapeLayer(), wordmarkMask=CAShapeLayer()
    private let mark=UIImageView(image:UIImage(named:"LaunchMark")), wordmark=UIImageView(image:UIImage(named:"SplashWordmark")); private var hasPlayed=false
    private var animationStartTime: CFTimeInterval = 0
    override init(frame:CGRect){super.init(frame:frame);backgroundColor=Palette.background;isUserInteractionEnabled=true;isAccessibilityElement=true;accessibilityViewIsModal=true;accessibilityIdentifier="mosquito-ninja-launch-overlay";accessibilityLabel="Mosquito Ninja. Bite Back.";configureHaze(redHaze,color:Palette.red,peakAlpha:0.23,center:CGPoint(x:0.5,y:0.47));layer.addSublayer(redHaze);configureHaze(greenHaze,color:Palette.green,peakAlpha:0.07,center:CGPoint(x:0.5,y:0.52));layer.addSublayer(greenHaze);stage.isUserInteractionEnabled=false;addSubview(stage);configureCircle(aura,color:Palette.red.withAlphaComponent(0.18),lineWidth:0);aura.shadowColor=Palette.red.cgColor;aura.shadowOpacity=0.68;aura.shadowRadius=54;aura.opacity=0;stage.layer.addSublayer(aura);configureCircle(burst,color:Palette.red.withAlphaComponent(0.72),lineWidth:1);burst.fillColor=UIColor.clear.cgColor;burst.shadowColor=Palette.red.cgColor;burst.shadowOpacity=0.5;burst.shadowRadius=18;burst.opacity=0;stage.layer.addSublayer(burst);configureCircle(orbit,color:UIColor.white.withAlphaComponent(0.14),lineWidth:1);orbit.fillColor=UIColor.clear.cgColor;orbit.opacity=0;stage.layer.addSublayer(orbit);redOrb.fillColor=Palette.red.cgColor;redOrb.shadowColor=Palette.red.cgColor;redOrb.shadowOpacity=0.95;redOrb.shadowRadius=7;orbit.addSublayer(redOrb);greenOrb.fillColor=Palette.green.cgColor;greenOrb.shadowColor=Palette.green.cgColor;greenOrb.shadowOpacity=0.9;greenOrb.shadowRadius=7;orbit.addSublayer(greenOrb);mark.contentMode = .scaleAspectFit;mark.alpha=0;mark.layer.shadowColor=UIColor.black.cgColor;mark.layer.shadowOpacity=0.72;mark.layer.shadowRadius=24;mark.layer.shadowOffset=CGSize(width:0,height:18);stage.addSubview(mark);configureStrike(strikeGlow,width:18,opacity:0.46);configureStrike(strike,width:7,opacity:1);stage.layer.addSublayer(strikeGlow);stage.layer.addSublayer(strike);strikeTip.fillColor=UIColor.white.cgColor;strikeTip.shadowColor=Palette.red.cgColor;strikeTip.shadowOpacity=1;strikeTip.shadowRadius=15;strikeTip.opacity=0;stage.layer.addSublayer(strikeTip);wordmark.contentMode = .scaleAspectFit;wordmark.alpha=0;wordmark.layer.shadowColor=Palette.red.cgColor;wordmark.layer.shadowOpacity=0.22;wordmark.layer.shadowRadius=14;wordmark.layer.mask=wordmarkMask;addSubview(wordmark)}
    required init?(coder:NSCoder){fatalError("init(coder:) has not been implemented")}
    override func layoutSubviews(){super.layoutSubviews();let compact=bounds.height<560;let isPad=traitCollection.userInterfaceIdiom == .pad;let markSize:CGFloat;let ww:CGFloat;if compact{markSize=min(bounds.height*0.58,bounds.width*0.52);ww=min(bounds.width*0.72,500)}else if isPad{markSize=min(min(bounds.width*0.60,bounds.height*0.48),560);ww=min(bounds.width*0.82,780)}else{markSize=min(min(bounds.width*0.92,bounds.height*0.48),400);ww=min(bounds.width*0.97,640)};let wh=ww*(361.0/1080.0);let overlap:CGFloat=compact ? 28:(isPad ? 46:38);let total=markSize+wh-overlap;let top=bounds.midY-total/2-(compact ? 0:bounds.height*0.018);stage.frame=CGRect(x:bounds.midX-markSize/2,y:top,width:markSize,height:markSize);mark.frame=stage.bounds;wordmark.frame=CGRect(x:bounds.midX-ww/2,y:stage.frame.maxY-overlap,width:ww,height:wh);redHaze.frame=bounds.insetBy(dx:-bounds.width*0.28,dy:-bounds.height*0.28);greenHaze.frame=bounds;[aura,burst,orbit,strikeGlow,strike,strikeTip].forEach{$0.frame=stage.bounds};let center=CGPoint(x:markSize/2,y:markSize/2);aura.path=UIBezierPath(ovalIn:stage.bounds.insetBy(dx:markSize*0.08,dy:markSize*0.08)).cgPath;burst.path=UIBezierPath(ovalIn:stage.bounds.insetBy(dx:markSize*0.04,dy:markSize*0.04)).cgPath;orbit.path=UIBezierPath(ovalIn:stage.bounds.insetBy(dx:0.5,dy:0.5)).cgPath;let rs=max(6,markSize*0.019);redOrb.path=UIBezierPath(ovalIn:CGRect(x:markSize*0.105,y:markSize*0.145,width:rs,height:rs)).cgPath;let gs=max(5,markSize*0.014);greenOrb.path=UIBezierPath(ovalIn:CGRect(x:markSize*0.915,y:markSize*0.745,width:gs,height:gs)).cgPath;let angle = -38.0*CGFloat.pi/180;let half=markSize*0.31;let sc=CGPoint(x:center.x,y:markSize*0.466);let delta=CGPoint(x:cos(angle)*half,y:sin(angle)*half);let start=CGPoint(x:sc.x-delta.x,y:sc.y-delta.y),end=CGPoint(x:sc.x+delta.x,y:sc.y+delta.y);let p=UIBezierPath();p.move(to:start);p.addLine(to:end);strikeGlow.path=p.cgPath;strike.path=p.cgPath;strikeGlow.lineWidth=max(15,markSize*0.052);strike.lineWidth=max(7,markSize*0.023);let tr=max(11,markSize*0.038);strikeTip.path=UIBezierPath(ovalIn:CGRect(x:end.x-tr,y:end.y-tr,width:tr*2,height:tr*2)).cgPath;wordmarkMask.frame=wordmark.bounds;wordmarkMask.path=UIBezierPath(rect:wordmark.bounds).cgPath}
    func play(){guard !hasPlayed else{return};hasPlayed=true;setNeedsLayout();layoutIfNeeded();if UIAccessibility.isReduceMotionEnabled{showReducedMotionSplash();return};animationStartTime=CACurrentMediaTime();animateAtmosphere();animateMark();animateStrike();animateWordmark();DispatchQueue.main.asyncAfter(deadline:.now()+1.04){NinjaHaptics.impact(.medium,intensity:0.9)};UIView.animate(withDuration:0.45,delay:3.55,options:[.curveEaseIn,.beginFromCurrentState]){self.alpha=0;self.transform=CGAffineTransform(scaleX:1.014,y:1.014)}completion:{_ in self.removeFromSuperview()}}
    private func configureCircle(_ l:CAShapeLayer,color:UIColor,lineWidth:CGFloat){l.fillColor=color.cgColor;l.strokeColor=color.cgColor;l.lineWidth=lineWidth}
    private func configureHaze(_ l:CAGradientLayer,color:UIColor,peakAlpha:CGFloat,center:CGPoint){l.type = .radial;l.colors=[color.withAlphaComponent(peakAlpha).cgColor,color.withAlphaComponent(peakAlpha*0.32).cgColor,UIColor.clear.cgColor];l.locations=[0,0.34,0.72];l.startPoint=center;l.endPoint=CGPoint(x:0.94,y:0.94);l.opacity=0}
    private func configureStrike(_ l:CAShapeLayer,width:CGFloat,opacity:Float){l.fillColor=UIColor.clear.cgColor;l.strokeColor=Palette.red.withAlphaComponent(CGFloat(opacity)).cgColor;l.lineWidth=width;l.lineCap = .round;l.shadowColor=Palette.red.cgColor;l.shadowOpacity=opacity;l.shadowRadius=width;l.strokeEnd=0}
    private func animateAtmosphere(){redHaze.opacity=1;animateScale(redHaze,values:[0.58,1],keyTimes:[0,1],duration:1.70,delay:0);animateOpacity(redHaze,values:[0,1],keyTimes:[0,1],duration:1.0,delay:0);greenHaze.opacity=0.7;animateOpacity(greenHaze,values:[0,0.7],keyTimes:[0,1],duration:1.18,delay:0.08);aura.opacity=0.88;animateScale(aura,values:[0.22,1.14,1],keyTimes:[0,0.58,1],duration:1.80,delay:0.04);animateOpacity(aura,values:[0,1,0.88],keyTimes:[0,0.58,1],duration:1.80,delay:0.04);burst.opacity=0;animateScale(burst,values:[0.22,1.68],keyTimes:[0,1],duration:0.92,delay:0.82);animateOpacity(burst,values:[0,0.82,0],keyTimes:[0,0.24,1],duration:0.92,delay:0.82);orbit.opacity=0.42;animateOpacity(orbit,values:[0,0.86,0.42],keyTimes:[0,0.42,1],duration:1.85,delay:0.06);animateRotation(orbit,from:-110 * CGFloat.pi / 180,to:50 * CGFloat.pi / 180,duration:1.85,delay:0.06)}
    private func animateMark() {
        mark.alpha = 1
        let entrance = CAKeyframeAnimation(keyPath: "transform")
        // Make the transform values passed to Core Animation explicit.
        entrance.values = [
            NSValue(caTransform3D: CATransform3DConcat(
                CATransform3DMakeScale(0.46, 0.46, 1),
                CATransform3DMakeRotation(-42 * .pi / 180, 0, 0, 1)
            )),
            NSValue(caTransform3D: CATransform3DConcat(
                CATransform3DMakeScale(1.07, 1.07, 1),
                CATransform3DMakeRotation(3 * .pi / 180, 0, 0, 1)
            )),
            NSValue(caTransform3D: CATransform3DIdentity)
        ]
        entrance.keyTimes = [0, 0.48, 1]
        entrance.duration = 1.32
        entrance.beginTime = animationTime(for: mark.layer, delay: 0.12)
        entrance.fillMode = .backwards
        entrance.timingFunction = CAMediaTimingFunction(controlPoints: 0.14, 0.76, 0.18, 1)
        mark.layer.add(entrance, forKey: "markEntrance")
        animateOpacity(mark.layer, values: [0, 1, 1], keyTimes: [0, 0.48, 1], duration: 1.32, delay: 0.12)
    }

    private func animateStrike() {
        [strikeGlow, strike].forEach { target in
            let begin = animationTime(for: target, delay: 1.02)
            target.strokeEnd = 1
            target.opacity = 0

            let draw = CABasicAnimation(keyPath: "strokeEnd")
            draw.fromValue = 0
            draw.toValue = 1
            draw.duration = 0.72
            draw.beginTime = begin
            draw.fillMode = .backwards
            target.add(draw, forKey: "strikeDraw")

            let fade = CAKeyframeAnimation(keyPath: "opacity")
            fade.values = [0, 1, 1, 0]
            fade.keyTimes = [0, 0.12, 0.72, 1]
            fade.duration = 0.72
            fade.beginTime = begin
            fade.fillMode = .backwards
            target.add(fade, forKey: "strikeFade")
        }
        animateScale(strikeTip, values: [0.2, 1, 1.7], keyTimes: [0, 0.35, 1], duration: 0.60, delay: 1.08)
        animateOpacity(strikeTip, values: [0, 1, 0], keyTimes: [0, 0.35, 1], duration: 0.60, delay: 1.08)
    }

    private func animateWordmark() {
        wordmark.alpha = 1
        let entrance = CAKeyframeAnimation(keyPath: "transform")
        entrance.values = [
            NSValue(caTransform3D: CATransform3DConcat(
                CATransform3DMakeTranslation(0, 20, 0),
                CATransform3DMakeScale(0.90, 0.90, 1)
            )),
            NSValue(caTransform3D: CATransform3DIdentity)
        ]
        entrance.keyTimes = [0, 1]
        entrance.duration = 1.02
        entrance.beginTime = animationTime(for: wordmark.layer, delay: 1.26)
        entrance.fillMode = .backwards
        entrance.timingFunction = CAMediaTimingFunction(controlPoints: 0.16, 0.82, 0.2, 1)
        wordmark.layer.add(entrance, forKey: "wordmarkEntrance")
        animateOpacity(wordmark.layer, values: [0, 1, 1], keyTimes: [0, 0.48, 1], duration: 1.02, delay: 1.26)

        let start = CGRect(x: wordmark.bounds.midX - 1, y: 0, width: 2, height: wordmark.bounds.height)
        let reveal = CABasicAnimation(keyPath: "path")
        reveal.fromValue = UIBezierPath(rect: start).cgPath
        reveal.toValue = UIBezierPath(rect: wordmark.bounds).cgPath
        reveal.duration = 1.02
        reveal.beginTime = animationTime(for: wordmarkMask, delay: 1.26)
        reveal.fillMode = .backwards
        wordmarkMask.add(reveal, forKey: "wordmarkReveal")
    }
    private func showReducedMotionSplash(){mark.alpha=1;redHaze.opacity=1;greenHaze.opacity=0.7;aura.opacity=0.82;orbit.opacity=0.38;wordmark.alpha=1;UIView.animate(withDuration:0.18,delay:0.42){self.alpha=0}completion:{_ in self.removeFromSuperview()}}
    private func animationTime(for target: CALayer, delay: CFTimeInterval) -> CFTimeInterval {
        // All effects share one start time, converted into each layer's clock.
        // A window's local timeline can differ from the system media clock.
        target.convertTime(animationStartTime + delay, from: nil)
    }

    private func animateScale(_ l:CALayer,values:[CGFloat],keyTimes:[NSNumber],duration:CFTimeInterval,delay:CFTimeInterval){let a=CAKeyframeAnimation(keyPath:"transform.scale");a.values=values;a.keyTimes=keyTimes;a.duration=duration;a.beginTime=animationTime(for:l,delay:delay);a.fillMode = .backwards;a.timingFunction=CAMediaTimingFunction(controlPoints:0.16,0.78,0.18,1);l.add(a,forKey:"scale-\(delay)")}
    private func animateOpacity(_ l:CALayer,values:[Float],keyTimes:[NSNumber],duration:CFTimeInterval,delay:CFTimeInterval){let a=CAKeyframeAnimation(keyPath:"opacity");a.values=values;a.keyTimes=keyTimes;a.duration=duration;a.beginTime=animationTime(for:l,delay:delay);a.fillMode = .backwards;l.add(a,forKey:"opacity-\(delay)")}
    private func animateRotation(_ l:CALayer,from:CGFloat,to:CGFloat,duration:CFTimeInterval,delay:CFTimeInterval){let a=CABasicAnimation(keyPath:"transform.rotation.z");a.fromValue=from;a.toValue=to;a.duration=duration;a.beginTime=animationTime(for:l,delay:delay);a.fillMode = .backwards;a.timingFunction=CAMediaTimingFunction(controlPoints:0.16,0.78,0.18,1);l.add(a,forKey:"rotation-\(delay)")}
}
