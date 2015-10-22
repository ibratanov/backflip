#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();


target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")


// UIATarget.onAlert = function onAlert(alert){
//     var title = alert.name();
//     UIALogger.logWarning("Alert with title ’" + title + "’ encountered!");
//     target.frontMostApp().alert().defaultButton().tap();
//     return false; // use default handler
// }


target.delay(2)

login()

target.delay(2)

captureLocalizedScreenshot("1-CurrentEvent")

target.delay(1)

checkin()

captureLocalizedScreenshot("2-CheckedIn")


target.delay(0.5);

target.frontMostApp().tabBar().buttons()["Event History"].tap();

captureLocalizedScreenshot("3-EventHistory")

target.delay(0.5);

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
	target.delay(1);
	
	target.tap({x:55.50, y:53.00});
	target.tap({x:55.50, y:53.00});
	target.tap({x:55.50, y:53.00});
	
	
	UIATarget.onAlert = function onAlert(alert)
	{
		var title = alert.name();
		UIALogger.logDebug("Caught onAlert: " + title);
		if (title.indexOf("to access your location while you use the app?") > -1) {
			alert.buttons()["Allow"].tap();
			target.delay(0.3);
			return true;
		}
		return false;
	};
	
	
	
	target.delay(0.5)
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