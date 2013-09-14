defmodule Readp do
    def parse(url, readability_key, pid // Kernel.self) do
        case :httpc.request 'https://readability.com/api/content/v1/parser?token=' ++ to_char_list(readability_key) ++ '&url=' ++ to_char_list(url) do
            {:ok, {{_,_,'OK'}, _, resp}} ->
                case JSEX.decode to_string(resp), [{:labels, :atom}] do
                    {:ok, parsed}   ->
                        pid <- {:ok, parsed[:title], parsed[:content]}
                    _               -> pid <- {:error}
                end
            err ->
                pid <- err
        end
    end

    defp accept :ok, list do
        receive do
            {:ok, title, content} ->
                accept :ok, list ++ [[{:title, title}, {:content, content}]]
            _ ->
                {:end?, list}
            after 1000 ->
                {:ok, list}
        end
    end


    def parse_multiple(urllist, readability_key) do
        :inets.start
        :ssl.start

        self = Kernel.self
        Enum.map urllist, fn url -> parse url, readability_key, self end

        accept :ok, []

    end
end
