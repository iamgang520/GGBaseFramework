//
//  ViewController.m
//  GGBaseFramework
//
//  Created by iamgang on 2022/9/6.
//

#import "ViewController.h"
#import "GGBaseURLManager.h"
#import "GGBaseIPNRSAUtil.h"

@interface ViewController ()

@property (nonatomic, strong) GGBaseURLManager *manager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.manager = [[GGBaseURLManager alloc] initWithURLs:@[
        @"https://im-gateway.center-im-production.allstarunion.com",
        @"https://im-gateway.center-im-production.allstarcluster.com",
        @"https://starunion-game-center-im-gateway.akamaized.net",
        @"https://im-gateway-center-im-production.staruniongame.com"
    ]];

    NSString *RSA_KEY = @"MIIBUwIBADANBgkqhkiG9w0BAQEFAASCAT0wggE5AgEAAkEA2c0tjaMuDecKPOey\n"
    "Tzyn3d6hXlsrOcTLZiHH5nTKZIy0QfnLCFt4OtR2dq3Nuv0+Uos3sP1/tsUg757l\n"
    "pl6rOQIDAQABAkBglTHsKz6S/690jrJtnNI7+yvH8dnbRj+ETNqegY/2wfS4avie\n"
    "yaf17lt+ObTK7+yiSdcdcZgWst26y15eNZK5AiEA34fEfFWZAIwBDjQ6C20rOiZM\n"
    "4SlTp7Z7ph7m1uvu6OcCIQD5cGA/79rO7a6phv3If+sSefM9ZWQiqVqVI4v8ZGSm\n"
    "3wIgDv5gY6aqOKsrdvRx4EpWV/Qxu/i1r85BxQbVnRz+TYkCICpN99UALgEIaKYR\n"
    "4freTxUMH8fa6VfDlzxSEgzVTgjLAiBVOc0ua16HKTFiahMLGDMuCwfBa6tE5fiY\n"
    "3lErZEu2OQ==";
    NSLog(@"%@", [GGBaseIPNRSAUtil sign:@"ts$12455221&account_id$1065545656&age1$29&country$chengdu&seed$3&device_id$dsadfaslkfwe" privateKey:RSA_KEY]);
}


@end
