#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")


UIATarget.onAlert = function onAlert(alert){
	var title = alert.name();
	UIALogger.logWarning("Alert with title ’" + title + "’ encountered!");
	target.frontMostApp().alert().defaultButton().tap();
	return false; // use default handler
}


target.delay(20)

login()

target.delay(5)

captureLocalizedScreenshot("1-CurrentEvent")

target.delay(1)

checkin()

captureLocalizedScreenshot("1-CheckedIn")


// target.setDeviceOrientation(UIA_DEVICE_ORIENTATION_PORTRAIT);
// target.frontMostApp().mainWindow().pickers()[0].wheels()[0].scrollToVisible();
// target.frontMostApp().mainWindow().pickers()[0].wheels()[0].scrollToVisible();



// Checking in
// target.frontMostApp().mainWindow().buttons()["CHECK IN"].tap();

// Event History
// target.frontMostApp().tabBar().buttons()["Event History"].tap();

// Random taps 
// target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.52, y:0.11}});
// target.frontMostApp().navigationBar().leftButton().tap();
// target.frontMostApp().mainWindow().collectionViews()[0].tapWithOptions({tapOffset:{x:0.54, y:0.12}});



function login()
{
	target.tap({x:155.00, y:501.00});
	target.tap({x:155.00, y:501.00});
	target.tap({x:155.00, y:501.00});
}


function logout()
{
	target.frontMostApp().tabBar().buttons()["Current Event"].tap();
	target.frontMostApp().navigationBar().leftButton().tap();
	// Alert detected. Expressions for handling alerts should be moved into the UIATarget.onAlert function definition.
	target.frontMostApp().alert().buttons()["Log Out"].tap();
}


function checkin()
{
	target.frontMostApp().tabBar().buttons()["Current Event"].tap(); // Ensure we're on the current event tab
	target.frontMostApp().mainWindow().buttons()["CHECK IN"].tap();
}