/**
 * Copyright (c) 2011 Muh Hon Cheng
 * Created by honcheng on 28/4/11.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining 
 * a copy of this software and associated documentation files (the 
 * "Software"), to deal in the Software without restriction, including 
 * without limitation the rights to use, copy, modify, merge, publish, 
 * distribute, sublicense, and/or sell copies of the Software, and to 
 * permit persons to whom the Software is furnished to do so, subject 
 * to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be 
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT 
 * WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR 
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
 * SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR 
 * THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 * @author 		Muh Hon Cheng <honcheng@gmail.com>
 * @copyright	2011	Muh Hon Cheng
 * @version
 * 
 */

#import "LineChartViewController.h"

@implementation LineChartViewController

- (void)viewDidLoad{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.lineChartView = [[PCLineChartView alloc] initWithFrame:CGRectMake(10,10,[self.view bounds].size.width-20,[self.view bounds].size.height-20)];
    self.lineChartView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    self.lineChartView.xLabelFont = [UIFont systemFontOfSize:0];
   
    self.lineChartView.minValue = 0;
    
    NSNumber *max = [self.data valueForKeyPath:@"@max.intValue"];
    self.lineChartView.maxValue = [max floatValue];
    [self.view addSubview:self.lineChartView];
    
    NSMutableArray *components = [NSMutableArray array];
    
    PCLineChartViewComponent *component = [[PCLineChartViewComponent alloc] init];
    component.title = self.chartTitle;
    component.points = self.data;
    component.shouldLabelValues = NO;
    
    component.colour = PCColorGreen;
    
    [components addObject:component];
    if (self.meanSpeed) {
        PCLineChartViewComponent *meanSpeedComponent = [[PCLineChartViewComponent alloc] init];
        meanSpeedComponent.title = @"Mean Speed";
        NSMutableArray *points = [[NSMutableArray alloc] init];
        for (NSNumber *time in self.time) {
            [points addObject:self.meanSpeed];
        }
        meanSpeedComponent.points = points;
        meanSpeedComponent.shouldLabelValues = NO;
        
        meanSpeedComponent.colour = PCColorBlue;
        [components addObject:meanSpeedComponent];
    }
    self.lineChartView.components = components;
    self.lineChartView.xLabels = self.time;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self.lineChartView setNeedsDisplay];
    return YES;
}

@end
