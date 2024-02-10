extends SelectorBase

class_name SelectorBoard

func getPreview() -> PreviewBase:
	return Preloader.previewBoard.instantiate()
