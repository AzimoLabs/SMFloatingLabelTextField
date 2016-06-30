//
//  SMFloatingLabelTextField.m
//  Pods
//
//  Created by Michał Moskała on 30.06.2016.
//
//

#import "SMFloatingLabelTextField.h"

NSString *const kSMFloatingLabelTextFieldTextKeyPath = @"text";

@interface SMFloatingLabelTextField ()
@property (nonatomic, strong, nonnull) UILabel *floatingLabel;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *floatingLabelTopSpaceConstraint;
@property (nonatomic, strong, nonnull) NSLayoutConstraint *floatingLabelLeadingConstraint;
@property (nonatomic, assign) BOOL isFloatingLabelBeingShown;
@end

@implementation SMFloatingLabelTextField

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self setupInitialInspectableAttributesValues];
    [self setupFloatingLabel];
    [self setupObservers];
}

- (void)setupInitialInspectableAttributesValues {
    self.floatingLabelPassiveColor = [UIColor lightGrayColor];
    self.floatingLabelActiveColor = [UIColor blueColor];
    self.floatingLabelFont = [UIFont systemFontOfSize:12.0];
    self.floatingLabelLeadingOffset = [self textRectForBounds:self.bounds].origin.x;
}

- (void)setupFloatingLabel {
    self.floatingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.floatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.floatingLabel.text = self.placeholder;
    self.floatingLabel.alpha = 0.0;
    self.floatingLabel.font = self.floatingLabelFont;
    self.floatingLabel.textColor = self.floatingLabelPassiveColor;
    [self insertSubview:self.floatingLabel atIndex:0];
    
    self.floatingLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.floatingLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:self.floatingLabelLeadingOffset];
    self.floatingLabelTopSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.floatingLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    [self addConstraints:@[self.floatingLabelLeadingConstraint, self.floatingLabelTopSpaceConstraint]];
}

- (void)setupObservers {
    [self addTarget:self action:@selector(textFieldBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(textFieldEndEditing) forControlEvents:UIControlEventEditingDidEnd];
    [self addTarget:self action:@selector(textDidChangeInteractively) forControlEvents:UIControlEventEditingChanged];
    [self addObserver:self forKeyPath:kSMFloatingLabelTextFieldTextKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - observing changes

- (void)textFieldBeginEditing {
    [self.floatingLabel setTextColor:self.floatingLabelActiveColor];
}

- (void)textFieldEndEditing {
    [self.floatingLabel setTextColor:self.floatingLabelPassiveColor];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kSMFloatingLabelTextFieldTextKeyPath]) {
        [self textDidChangeProgramatically];
    }
}

- (void)textDidChangeInteractively {
    [self handleFloatingLabelStateForCurrentTextAnimated:YES];
}

- (void)textDidChangeProgramatically {
    [self handleFloatingLabelStateForCurrentTextAnimated:NO];
}

- (void)handleFloatingLabelStateForCurrentTextAnimated:(BOOL)animated {
    if (self.text.length == 0) {
        [self hideFloatingLabelAnimated:animated];
        self.isFloatingLabelBeingShown = YES;
    } else {
        [self showFloatingLabelAnimated:animated];
        self.isFloatingLabelBeingShown = NO;
    }
}

- (void)showFloatingLabelAnimated:(BOOL)animated {
    self.floatingLabelTopSpaceConstraint.constant = 0.0;
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.floatingLabel.alpha = 1.0;
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        self.floatingLabel.alpha = 1.0;
        [self layoutIfNeeded];
    }
}

- (void)hideFloatingLabelAnimated:(BOOL)animated {
    self.floatingLabelTopSpaceConstraint.constant = CGRectGetMidY(self.bounds) - CGRectGetMidY(self.floatingLabel.bounds);
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.floatingLabel.alpha = 0.0;
            [self layoutIfNeeded];
        } completion:nil];
    } else {
        self.floatingLabel.alpha = 0.0;
        [self layoutIfNeeded];
    }
}

#pragma mark - public methods

- (void)setFloatingLabelFont:(UIFont *)floatingLabelFont {
    _floatingLabelFont = floatingLabelFont;
    self.floatingLabel.font = floatingLabelFont;
}

- (void)setFloatingLabelLeadingOffset:(CGFloat)floatingLabelLeadingOffset {
    _floatingLabelLeadingOffset = floatingLabelLeadingOffset;
    self.floatingLabelLeadingConstraint.constant = floatingLabelLeadingOffset;
    [self setNeedsLayout];
}

- (void)setFloatingLabelActiveColor:(UIColor *)floatingLabelActiveColor {
    _floatingLabelActiveColor = floatingLabelActiveColor;
    if (self.isFloatingLabelBeingShown) {
        self.floatingLabel.textColor = floatingLabelActiveColor;
    }
}

- (void)setFloatingLabelPassiveColor:(UIColor *)floatingLabelPassiveColor {
    _floatingLabelPassiveColor = floatingLabelPassiveColor;
    if (!self.isFloatingLabelBeingShown) {
        self.floatingLabel.textColor = floatingLabelPassiveColor;
    }
}

#pragma mark - overriden method

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    self.floatingLabel.text = placeholder;
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeObserver:self forKeyPath:kSMFloatingLabelTextFieldTextKeyPath];
}

@end
