//
//  IMOWalletViewController.m
//  iMods
//
//  Created by Brendon Roberto on 10/22/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#import "IMOWalletViewController.h"
#import "IMOSessionManager.h"

@interface IMOWalletViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IMOSessionManager *sessionManager;

- (UITableViewCell *)configureCell: (UITableViewCell *)cell withBillingInfo: (IMOBillingInfo *)info;
- (IBAction)newButtonTapped:(id)sender;
@end

@implementation IMOWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.sessionManager = [IMOSessionManager sharedSessionManager];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // Refresh billing methods
    [self.sessionManager.billingManager refreshBillingMethods].then(^{
        [self.tableView reloadData];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.sessionManager.billingManager.isBillingMethodSelected) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.sessionManager.billingManager.selectedBillingMethod inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"wallet_card_modal"]) {
        ((IMOCardViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessionManager.billingManager.billingMethods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    IMOBillingInfo *billingInfo = self.sessionManager.billingManager.billingMethods[indexPath.row];

    cell = [self configureCell:cell withBillingInfo:billingInfo];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sessionManager.billingManager.isBillingMethodSelected = YES;
    self.sessionManager.billingManager.selectedBillingMethod = indexPath.row;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (indexPath.row == self.sessionManager.billingManager.selectedBillingMethod) {
            self.sessionManager.billingManager.isBillingMethodSelected = NO;
        }
        [self.sessionManager.billingManager removeBillingMethodAtIndex:indexPath.row].then(^{
            [tableView endEditing:YES];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        });
    }
}


#pragma mark - IMOCardDelegate

- (void)cardControllerDidCancel:(IMOCardViewController *)cardController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withCard:(PTKCard *)card {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cardControllerDidFinish:(IMOCardViewController *)cardController withBillingInfo:(IMOBillingInfo *)info {
    NSLog(@"Dismissing CardController with BillingInfo: %@", info);
    [self dismissViewControllerAnimated:YES completion:nil];

    __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.tableView addSubview:indicator];
    [indicator startAnimating];
    [self.sessionManager.billingManager addNewBillingMethod:info].then(^{
        [self.sessionManager.billingManager refreshBillingMethods].then(^{
            [indicator stopAnimating];
            [indicator removeFromSuperview];
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Misc

- (UITableViewCell *)configureCell:(UITableViewCell *)cell withBillingInfo:(IMOBillingInfo *)info {
    
    NSString *cardDetailText;
    
    switch (info.paymentType) {
        case Paypal:
            cell.textLabel.text = @"Paypal";
            cardDetailText = @"Paypal Payment";
            break;
        case CreditCard:
            cell.textLabel.text = @"Stripe";
            cardDetailText = [NSString stringWithFormat:@"%@'s card ending in %@", info.creditcardName, [info.creditcardNumber substringFromIndex: MAX((int)[info.creditcardNumber length] - 4, 0)]];
            break;
        default:
            cell.textLabel.text = @"Unknown";
            cardDetailText = @"Unknown Payment";
            break;
    }
    
    cell.detailTextLabel.text = cardDetailText;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (IBAction)newButtonTapped:(id)sender {
    [self performSegueWithIdentifier: @"wallet_card_modal" sender:self];
}

@end
