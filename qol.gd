extends Node

func create_atk(enemy: bool = false) :
  var atk := AtkBuilder.new()
  
  return atk.create_atk(get_tree(), enemy)

func create_timer(timeout: Callable, time: float = 1) :
  var t := Timer.new()

  get_tree().get_root().add_child.call_deferred(t)
  
  t.wait_time = time
  t.one_shot = true
  t.autostart = true
  t.timeout.connect(func():
    t.queue_free()
    timeout.call()
  )
