#pragma clang diagnostic ignored "-Wdeprecated-declarations" #import <UIKit/UIKit.h> #import <objc/runtime.h>
// ========================================================== // الجزء 1: كود البايباس (Bypass) من ملف facetimecode.txt // ========================================================== @interface UIViewController (BypassFilza) @end
@implementation UIViewController (BypassFilza)
(void)load { static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{ Method origPres = class_getInstanceMethod([UIViewController class], @selector(presentViewController:animated:completion:)); Method swizPres = class_getInstanceMethod([UIViewController class], @selector(custom_presentViewController:animated:completion:)); method_exchangeImplementations(origPres, swizPres); }); }
(void)custom_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion { if ([viewControllerToPresent isKindOfClass:[UIAlertController class]]) { UIAlertController *alert = (UIAlertController *)viewControllerToPresent;
  NSString *title = alert.title ? alert.title.lowercaseString : @"";
  NSString *message = alert.message ? alert.message.lowercaseString : @"";
  
  BOOL isLicenseOrModifyAlert = [title containsString:@"modified"] || 
                               [message containsString:@"modified"] ||
                               [title containsString:@"activate"] || 
                               [message containsString:@"activate"] ||
                               [title containsString:@"license"] || 
                               [message containsString:@"license"];
  
  if (isLicenseOrModifyAlert) {
      if (completion) completion();
      return;
  }
}
[self custom_presentViewController:viewControllerToPresent animated:flag completion:completion]; } @end
// ========================================================== // الجزء 2: واجهة إدارة الملفات (Filza Swap Panel) // ==========================================================
@class DetailViewController;
@interface MainPanelController : UIViewController <UITableViewDataSource, UITableViewDelegate> @property (nonatomic, strong) NSMutableArray *itemsArray; @property (nonatomic, strong) UITableView *tableView; @end
@interface DetailViewController : UIViewController @property (nonatomic, strong) NSDictionary *patchData; @end
@implementation MainPanelController
(void)viewDidLoad { [super viewDidLoad]; self.view.backgroundColor = [UIColor blackColor]; self.title = @"FILZA SWAP";
self.navigationController.navigationBar.barStyle = UIBarStyleBlack; self.navigationController.navigationBar.tintColor = [UIColor systemGreenColor]; self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
NSArray *savedItems = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FilzaSwapPatches"]; if (savedItems) { self.itemsArray = [NSMutableArray arrayWithArray:savedItems]; } else { self.itemsArray = [NSMutableArray array]; }
UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapAddButton)]; addButton.tintColor = [UIColor systemGreenColor]; self.navigationItem.rightBarButtonItem = addButton;
self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped]; self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; self.tableView.backgroundColor = [UIColor blackColor]; self.tableView.dataSource = self; self.tableView.delegate = self; [self.view addSubview:self.tableView]; }
(void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; [self.tableView reloadData]; }
(void)didTapAddButton { UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nouveau Patch" message:@"Entrez les informations de swap" preferredStyle:UIAlertControllerStyleAlert];
[alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Nom du patch"; tf.keyboardAppearance = UIKeyboardAppearanceDark; }]; [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Activar: Chemin Destination"; tf.keyboardAppearance = UIKeyboardAppearanceDark; }]; [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Activar: Chemin Source"; tf.keyboardAppearance = UIKeyboardAppearanceDark; }]; [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Desactivar: Chemin Destination"; tf.keyboardAppearance = UIKeyboardAppearanceDark; }]; [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) { tf.placeholder = @"Desactivar: Chemin Source"; tf.keyboardAppearance = UIKeyboardAppearanceDark; }];
[alert addAction:[UIAlertAction actionWithTitle:@"Enregistrer" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { NSString *name = alert.textFields[0].text; NSString *actDest = alert.textFields[1].text; NSString *actSrc = alert.textFields[2].text; NSString *desDest = alert.textFields[3].text; NSString *desSrc = alert.textFields[4].text;
  if (name.length > 0) {
      NSDictionary *dict = @{
          @"name": name,
          @"actDest": actDest ?: @"",
          @"actSrc": actSrc ?: @"",
          @"desDest": desDest ?: @"",
          @"desSrc": desSrc ?: @""
      };
      [self.itemsArray addObject:dict];
      [[NSUserDefaults standardUserDefaults] setObject:self.itemsArray forKey:@"FilzaSwapPatches"];
      [[NSUserDefaults standardUserDefaults] synchronize];
      [self.tableView reloadData];
  }
}]]; [alert addAction:[UIAlertAction actionWithTitle:@"Annuler" style:UIAlertActionStyleCancel handler:nil]]; [self presentViewController:alert animated:YES completion:nil]; }
(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.itemsArray.count; }
(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath { static NSString *cellID = @"PatchCell"; UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID]; if (!cell) { cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID]; cell.backgroundColor = [UIColor colorWithWhite:0.12 alpha:1.0]; cell.textLabel.textColor = [UIColor whiteColor]; cell.detailTextLabel.textColor = [UIColor grayColor]; cell.layer.cornerRadius = 10; cell.layer.masksToBounds = YES; }
NSDictionary *item = self.itemsArray[indexPath.row]; cell.textLabel.text = item[@"name"]; cell.textLabel.font = [UIFont boldSystemFontOfSize:16]; cell.detailTextLabel.text = @"1 replacement rule"; cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
return cell; }
(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { [tableView deselectRowAtIndexPath:indexPath animated:YES]; NSDictionary *item = self.itemsArray[indexPath.row];
DetailViewController *detailVC = [[DetailViewController alloc] init]; detailVC.patchData = item; [self.navigationController pushViewController:detailVC animated:YES]; }
@end
@implementation DetailViewController
(void)viewDidLoad { [super viewDidLoad]; self.view.backgroundColor = [UIColor blackColor]; self.title = self.patchData[@"name"];
UIButton *activateButton = [UIButton buttonWithType:UIButtonTypeCustom]; activateButton.frame = CGRectMake(30, 160, self.view.frame.size.width - 60, 55); activateButton.backgroundColor = [UIColor colorWithRed:0.05 green:0.2 blue:0.05 alpha:1.0]; [activateButton setTitle:@"  🛡️  ACTIVAR" forState:UIControlStateNormal]; [activateButton setTitleColor:[UIColor systemGreenColor] forState:UIControlStateNormal]; activateButton.titleLabel.font = [UIFont boldSystemFontOfSize:16]; activateButton.layer.cornerRadius = 12; activateButton.layer.borderWidth = 1.5; activateButton.layer.borderColor = [UIColor systemGreenColor].CGColor; [activateButton addTarget:self action:@selector(didTapActivate) forControlEvents:UIControlEventTouchUpInside]; [self.view addSubview:activateButton];UIButton *deactivateButton = [UIButton buttonWithType:UIButtonTypeCustom]; deactivateButton.frame = CGRectMake(30, 235, self.view.frame.size.width - 60, 55); deactivateButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.05 blue:0.05 alpha:1.0]; [deactivateButton setTitle:@"  🔄  DESACTIVAR" forState:UIControlStateNormal]; [deactivateButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal]; deactivateButton.titleLabel.font = [UIFont boldSystemFontOfSize:16]; deactivateButton.layer.cornerRadius = 12; deactivateButton.layer.borderWidth = 1.5; deactivateButton.layer.borderColor = [UIColor systemRedColor].CGColor; [deactivateButton addTarget:self action:@selector(didTapDeactivate) forControlEvents:UIControlEventTouchUpInside]; [self.view addSubview:deactivateButton]; }
(void)didTapActivate { NSString *destPath = self.patchData[@"actDest"]; NSString *sourcePath = self.patchData[@"actSrc"];
NSFileManager *fileManager = [NSFileManager defaultManager]; NSError *error = nil;
if (![fileManager fileExistsAtPath:sourcePath]) { [self showAlertWithTitle:@"Erreur" message:@"Fichier source introuvable."]; return; }
NSData *sourceData = [NSData dataWithContentsOfFile:sourcePath options:0 error:&error]; if (!sourceData) { [self showAlertWithTitle:@"Erreur" message:[NSString stringWithFormat:@"Lecture source échouée: %@", error.localizedDescription]]; return; }
NSString *destDir = [destPath stringByDeletingLastPathComponent]; [fileManager createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:&error];
BOOL success = [sourceData writeToFile:destPath options:NSDataWritingAtomic error:&error]; if (success) { [self showAlertWithTitle:@"Done" message:@"Activé avec succès"]; } else { [self showAlertWithTitle:@"Erreur d'écriture" message:error ? error.localizedDescription : @"Erreur inconnue"]; } }
(void)didTapDeactivate { NSString *destPath = self.patchData[@"desDest"]; NSString *sourcePath = self.patchData[@"desSrc"];
NSFileManager *fileManager = [NSFileManager defaultManager]; NSError *error = nil;
if (sourcePath.length > 0 && [fileManager fileExistsAtPath:sourcePath]) { NSData *sourceData = [NSData dataWithContentsOfFile:sourcePath options:0 error:&error]; if (sourceData) { NSString *destDir = [destPath stringByDeletingLastPathComponent]; [fileManager createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:&error]; [sourceData writeToFile:destPath options:NSDataWritingAtomic error:&error]; } } else if (destPath.length > 0) { if ([fileManager fileExistsAtPath:destPath]) { [fileManager removeItemAtPath:destPath error:&error]; } }
[self showAlertWithTitle:@"Done" message:@"Désactivé avec succès"]; }
(void)showAlertWithTitle:(NSString *)title message:(NSString *)message { UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]]; [self presentViewController:alert animated:YES completion:nil]; }
@end
attribute((constructor)) static void initFilzaSwap() { dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ UIWindow *window = nil; for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) { if (scene.activationState == UISceneActivationStateForegroundActive) { for (UIWindow *w in scene.windows) { if (w.isKeyWindow) { window = w; break; } } } } if (!window) { window = [UIApplication sharedApplication].windows.firstObject; }
    if (window) {
        MainPanelController *mainVC = [[MainPanelController alloc] init];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:mainVC];
        window.rootViewController = navC;
        [window makeKeyAndVisible];
    }
});
}
