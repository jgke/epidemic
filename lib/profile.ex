defmodule Profile do
  @moduledoc false
  import ExProf.Macro

  def go do
    profile do
      Epidemic.main(["40", "3", "40", "1.5", "false"])
    end
  end
end
