
#import "ViewController.h"
@import WebKit;

@interface ViewController ()<NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>

#pragma mark - Request
@property (weak) IBOutlet NSTextField *requestLabel;
@property (weak) IBOutlet NSPopUpButton *methodPopUp;
@property (weak) IBOutlet NSTextField *addressTextField;
@property (weak) IBOutlet NSButton *goButton;
@property (nonatomic) NSMutableDictionary <NSString *, NSString *> *requestHeaders;
@property (weak) IBOutlet NSTableView *requestHeadersTableView;

#pragma mark - Response
@property (weak) IBOutlet NSTextField *responseLabel;
@property (weak) IBOutlet NSTableView *responseHeadersTableView;
@property (weak) IBOutlet NSTextField *responseRawTextField;
@property (weak) IBOutlet WKWebView *responseWebView;

// Keep the response and data for display purposes.
@property (nonatomic) NSHTTPURLResponse *response;
@property (nonatomic) NSData *responseData;

@end

@implementation ViewController

- (void)performRequest;
{
    NSString *urlString = self.addressTextField.stringValue;
    if (!urlString.hasHTTPPrefix) {
        urlString = [@"https://" stringByAppendingString:urlString];
        self.addressTextField.stringValue = urlString;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                              httpMethod:self.methodPopUp.titleOfSelectedItem
                                                 headers:self.requestHeaders];

    [[NSURLSession.sharedSession dataTaskWithRequest:request
                                   completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            error ? [self handleError:error] : [self handleResponse:(NSHTTPURLResponse *)response data:data];
        });
    }] resume];
}

- (void)handleError:(NSError *)error;
{
    self.response = nil;
    self.responseData = nil;
    // TODO: handle error
}

- (void)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data;
{
    self.response = response;
    self.responseData = data;

    self.responseRawTextField.stringValue = [self.responseData stringWithEncoding:self.response.stringEncoding];
    [self.responseWebView loadHTMLString:self.responseRawTextField.stringValue
                                 baseURL:self.response.URL.baseURL];
    [self.responseHeadersTableView reloadData];
}

#pragma mark - NSViewController Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestHeaders = NSMutableDictionary.new;
    self.requestHeaders[@"edit"] = @"edit";
    self.goButton.enabled = NO;
}

#pragma mark - IBActions

- (IBAction)goButtonAction:(NSButton *)sender;
{
    [self performRequest];
}

- (IBAction)addressFieldAction:(NSTextField *)sender;
{
    [self performRequest];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return tableView == self.requestHeadersTableView ? self.requestHeaders.count : self.response.allHeaderFields.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSString *cellIdentifier = [tableColumn.identifier stringByAppendingString:@"Cell"];
    NSTableCellView *view = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
    
    // request
    if ([tableColumn.identifier isEqualToString:@"requestHeader"]) {
        view.textField.stringValue = self.requestHeaders.allKeys[row];
    } else if ([tableColumn.identifier isEqualToString:@"requestValue"]) {
        view.textField.stringValue = self.requestHeaders.allValues[row];
    }
    // response
    else if ([tableColumn.identifier isEqualToString:@"responseHeader"]) {
        view.textField.stringValue = self.response.allHeaderFields.allKeys[row];
    } else if ([tableColumn.identifier isEqualToString:@"responseValue"]) {
        view.textField.stringValue = self.response.allHeaderFields.allValues[row];
    }
    return view;
}

#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSLog(@"setting %@ for %@ at %li", [object description], tableColumn.identifier, row);
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj;
{
    self.goButton.enabled = self.addressTextField.stringValue.length > 0;
}

@end
