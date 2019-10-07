defmodule RoboticaFaceWeb.Live.Messages do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Last message: <%= inspect @action %>
    """
  end

  def mount(_, socket) do
    RoboticaFace.Scenes.register(self())
    {:ok, assign(socket, :action, nil)}
  end

  def handle_cast({:execute, action}, socket) do
    {:noreply, assign(socket, :action, action)}
  end
end
