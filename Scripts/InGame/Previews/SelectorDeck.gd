extends SelectorBase

class_name SelectorDeck

func getPreview() -> PreviewBase:
	return Preloader.previewDeck.instantiate()
