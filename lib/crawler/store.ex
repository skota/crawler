defmodule Crawler.Store do
  @moduledoc """
  An internal data store for information related to each crawl.
  """

  alias Crawler.Store.DB
  alias Crawler.Store.Page

  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @doc """
  Initialises a new `Registry` named `Crawler.Store.DB`.
  """
  def init(args) do
    Registry.start_link(keys: :unique, name: DB)

    {:ok, args}
  end

  @doc """
  Finds a stored URL and returns its page data.
  """
  def find(url) do
    case Registry.lookup(DB, url) do
      [{_, page}] -> page
      _ -> nil
    end
  end

  @doc """
  Finds a stored URL and returns its page data only if it's processed.
  """
  def find_processed(url) do
    case Registry.match(DB, url, %{processed: true}) do
      [{_, page}] -> page
      _ -> nil
    end
  end

  @doc """
  Adds a URL to the registry.
  """
  def add(url) do
    Registry.register(DB, url, %Page{url: url})
  end

  @doc """
  Adds the page data for a URL to the registry.
  """
  def add_page_data(url, body, opts) do
    {_new, _old} = Registry.update_value(DB, url, &%{&1 | body: body, opts: opts})
  end

  @doc """
  Marks a URL as processed in the registry.
  """
  def processed(url) do
    {_new, _old} = Registry.update_value(DB, url, &%{&1 | processed: true})
  end

  def all_urls do
    Registry.select(DB, [{{:"$1", :_, :_}, [], [:"$1"]}])
  end
end
