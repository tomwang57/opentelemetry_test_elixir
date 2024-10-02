# lib/roll_dice_web/controllers/dice_controller.ex
defmodule RollDiceWeb.DiceController do
  use RollDiceWeb, :controller
  require OpenTelemetry.Tracer, as: Tracer

  def roll(conn, _params) do
    send_resp(conn, 200, roll_dice())
  end

  defp roll_dice do
    Tracer.with_span "dice_roll" do
      roll = Enum.random(1..6)

      Tracer.set_attribute(:roll, roll)

      to_string(roll)
    end
  end
end
