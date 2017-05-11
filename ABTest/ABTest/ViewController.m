//
//  ViewController.m
//  ABTest
//
//  Created by HeT on 17/5/8.
//  Copyright © 2017年 chengsl. All rights reserved.
//

#import "ViewController.h"
#import "ABHandle.h"
#import "UIViewController+Alert.h"

#import "ABModel.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) ABHandle *handle;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(50, 100, self.view.bounds.size.width-100, 50)];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn setTitle:@"retry" forState:UIControlStateNormal];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(retry) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(retry) name:kABContactChangeName object:nil];
}

- (void)retry{
    __weak ViewController *weakSelf = self;
    [self.handle fetchContactsWithFailureBlock:^(NSError *error) {
        __strong ViewController *strongSelf = weakSelf;
        [strongSelf showErrorWith:error];
    } completBlock:^(id content) {
        NSMutableArray *contactsM = [NSMutableArray arrayWithArray:self.dataSource];
        [contactsM removeAllObjects];
        [contactsM addObjectsFromArray:content];
        self.dataSource = [contactsM copy];
        [self.tableView reloadData];
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.handle = [[ABHandle alloc]init];
    __weak ViewController *weakSelf = self;
    
    [self.handle requestAccessWithFailureBlock:^(NSError *error) {
        __strong ViewController *strongSelf = weakSelf;
        [strongSelf showErrorWith:error];
    } completBlock:^(id content) {
        NSLog(@"%@",content);
    }];
    
    [self.handle fetchContactsWithFailureBlock:^(NSError *error) {
        __strong ViewController *strongSelf = weakSelf;
        [strongSelf showErrorWith:error];
    } completBlock:^(id content) {
        NSMutableArray *contactsM = [NSMutableArray arrayWithArray:self.dataSource];
        [contactsM removeAllObjects];
        [contactsM addObjectsFromArray:content];
        self.dataSource = [contactsM copy];
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"ABContactsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    ABModel *model = self.dataSource[indexPath.row];
    cell.textLabel.text = model.fullName;
    NSMutableString *phones = [NSMutableString stringWithCapacity:model.phoneNums.count];
    for (NSString *phone in model.phoneNums) {
        [phones appendString:phone];
        [phones appendString:@" "];
    }
    cell.detailTextLabel.text = [phones copy];
    return cell;
}
@end
