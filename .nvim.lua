-- .nvim.lua
-- If you have more than one setup configured you will be prompted when you run
-- your app to select which one you want to use
require("flutter-tools").setup_project({
	{
		name = "windows",
		device = "windows",
		target = "lib/main.dart",
	},
	{
		name = "android",
		device = "R52R10BLV4L",
		target = "lib/main.dart",
	},
})
