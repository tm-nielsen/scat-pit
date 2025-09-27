extends Label

func _ready():
    print(AudioServer.get_output_device_list())


func receive_transcription(is_partial: bool, new_text: String):
    print(is_partial, new_text)
    text = new_text;
