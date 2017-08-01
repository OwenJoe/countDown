//
//  ViewController.m
//  GCD倒计时
//
//  Created by owen on 2017/8/1.
//  Copyright © 2017年 owen. All rights reserved.
//

//参考:http://blog.csdn.net/codingfire/article/details/52329856

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,strong) id timer;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /***********
     1.关于GCD倒计时,实际开发中遇到的问题在于线程使用,要知道倒计时每次改变都是在主线程对按钮的UI进行重新绘制,所以必须保证倒计时按钮变化的通知,其他操作要在其他线程,否则,页面卡死,卡顿将会出现
     2.一般用到倒计时,大多是在收取验证码,当收到验证码,填写完毕的时候,点击进行其他操作,必须杀死/停止当前线程,否则只能等到倒计时为0方可进行,道理就是如1所描述
     **********/

    [_startButton setTitle:@"获取验证码" forState:UIControlStateNormal];


}


/**
 GCD开始倒计时

 @param sender <#sender description#>
 */
- (IBAction)start:(id)sender {
    
    
    __block NSInteger second = 60;
    //全局队列    默认优先级
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //定时器模式  事件源
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    
    _timer = timer;
    
    //NSEC_PER_SEC是秒，＊1是每秒
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
    dispatch_source_set_event_handler(timer, ^{
        //回调主线程，在主线程中操作UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (second >= 0) {
                [_startButton setTitle:[NSString stringWithFormat:@"(%ld)重发验证码",second] forState:UIControlStateNormal];
                second--;
            }
            else
            {
                //这句话必须写否则会出问题
                dispatch_source_cancel(timer);
                [_startButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                
            }
        });
    });
    //启动源
    dispatch_resume(timer);

}


/**
 GCD停止计时

 @param sender <#sender description#>
 */
- (IBAction)stop:(id)sender {
    
    dispatch_source_cancel(_timer) ;
}

@end
