defmodule Readp do

    def xml_quote(str) do
        str |> to_string |> String.replace("&", "&amp;") |> String.replace("<", "&lt;") |> String.replace(">", "&gt;") |> String.replace("\"", "&quot;")
    end

    def parse(url, readability_key) do
        case :httpc.request 'https://readability.com/api/content/v1/parser?token=' ++ to_char_list(readability_key) ++ '&url=' ++ to_char_list(url) do
            {:ok, {{_,_,'OK'}, _, resp}} ->
                case JSEX.decode to_string(resp), [{:labels, :atom}] do
                    {:ok, parsed}   -> {:ok, parsed[:title], parsed[:content]}
                    _               -> {:error}
                end
            err ->
                err
        end
    end

    defp accept :ok, list do
        receive do
            {:ok, item} ->
                accept :ok, list ++ [item]
            _ ->
                {:ok, list}
            after 1000 ->
                {:ok, list}
        end
    end


    def parse_multiple(itemlist, readability_key, pid // self) do
        :inets.start
        :ssl.start

        Enum.map itemlist, fn item ->
            case parse item[:link], readability_key do
                {:ok, title, content} ->
                    pid <- {:ok, [title: xml_quote(title), summary: xml_quote(content <> "<hr>" <> item[:summary]), link: xml_quote(item[:link]), clients: item[:clients]]}
                _ -> {:error}
                end
        end

        accept :ok, []

    end
end
