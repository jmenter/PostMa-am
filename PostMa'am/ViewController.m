
@import WebKit;
#import "ViewController.h"

@interface ViewController ()<NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>

#pragma mark - Request
@property (weak) IBOutlet NSTextField *requestLabel;
@property (weak) IBOutlet NSPopUpButton *methodPopUp;
@property (weak) IBOutlet NSTextField *addressTextField;
@property (weak) IBOutlet NSButton *goButton;
@property (nonatomic) NSMutableDictionary <NSString *, NSString *> *requestHeaders;
@property (weak) IBOutlet NSTableView *requestHeadersTableView;

#pragma mark - Response

@property (nonatomic) NSHTTPURLResponse *response;
@property (weak) IBOutlet NSTextField *responseLabel;
@property (weak) IBOutlet NSTableView *responseHeadersTableView;
@property (weak) IBOutlet NSTextField *responseRawTextField;
@property (weak) IBOutlet WKWebView *responseWebView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestHeaders = NSMutableDictionary.new;
    [self.methodPopUp removeAllItems];
    [self.methodPopUp addItemsWithTitles:@[@"GET", @"HEAD", @"PUT", @"PATCH", @"DELETE", @"POST", @"OPTIONS", @"TRACE", @"CONNECT"]];
    self.goButton.enabled = NO;
}

- (IBAction)goButtonAction:(NSButton *)sender;
{
    [self performRequest];
}

- (IBAction)addressFieldAction:(NSTextField *)sender;
{
    [self performRequest];
}

- (void)performRequest;
{
    NSString *urlString = self.addressTextField.stringValue;
    if (!([urlString hasPrefix:@"http://"] || [urlString hasPrefix:@"https://"])) {
        urlString = [@"https://" stringByAppendingString:urlString];
        self.addressTextField.stringValue = urlString;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = self.methodPopUp.titleOfSelectedItem;
    request.allHTTPHeaderFields = self.requestHeaders;

    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{ error ? [self handleError:error] : [self handleResponse:(NSHTTPURLResponse *)response data:data]; });
    }] resume];
}

- (void)handleError:(NSError *)error;
{
    self.response = nil;
}

- (void)handleResponse:(NSHTTPURLResponse *)response data:(NSData *)data;
{
    self.response = response;
    NSString *responseEncoding = self.response.textEncodingName ?: @"utf8";
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)responseEncoding));
    self.responseRawTextField.stringValue = [NSString.alloc initWithData:data encoding:encoding];
    [self.responseWebView loadHTMLString:self.responseRawTextField.stringValue baseURL:response.URL.baseURL];
    [self.responseHeadersTableView reloadData];
}

- (void)controlTextDidChange:(NSNotification *)obj;
{
    self.goButton.enabled = self.addressTextField.stringValue.length > 0;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return tableView == self.requestHeadersTableView ? self.requestHeaders.count : self.response.allHeaderFields.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    NSTableCellView *view;
    if (tableView == self.requestHeadersTableView) {
        if ([tableColumn.identifier isEqualToString:@"requestHeader"]) {
            view = [tableView makeViewWithIdentifier:@"requestHeaderCell" owner:self];
            view.textField.stringValue = self.requestHeaders.allKeys[row];
        } else if ([tableColumn.identifier isEqualToString:@"requestValue"]) {
            view = [tableView makeViewWithIdentifier:@"requestValueCell" owner:self];
            view.textField.stringValue = self.requestHeaders.allValues[row];
        }
    } else if (tableView == self.responseHeadersTableView) {
        if ([tableColumn.identifier isEqualToString:@"responseHeader"]) {
            view = [tableView makeViewWithIdentifier:@"responseHeaderCell" owner:self];
            view.textField.stringValue = self.response.allHeaderFields.allKeys[row];

        } else if ([tableColumn.identifier isEqualToString:@"responseValue"]) {
            view = [tableView makeViewWithIdentifier:@"responseValueCell" owner:self];
            view.textField.stringValue = self.response.allHeaderFields.allValues[row];
        }
    }
    return view;
}

@end
