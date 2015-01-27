PROJECT=Catalog.xcodeproj
SCHEME=Catalog

test:
	xcodebuild test -project $(PROJECT) -scheme $(SCHEME) | bundle exec xcpretty -t
