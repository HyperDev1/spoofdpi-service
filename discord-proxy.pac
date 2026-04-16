// PAC (Proxy Auto-Config) — Sadece Discord trafiğini SpoofDPI'a yönlendir
function FindProxyForURL(url, host) {
    var dominated = [
        "discord.com",
        "discordapp.com",
        "discord.gg",
        "discord.media",
        "discordapp.net",
        "discord.new",
        "discordstatus.com",
        "dis.gd",
        "discord.co"
    ];

    for (var i = 0; i < dominated.length; i++) {
        if (dnsDomainIs(host, dominated[i]) ||
            dnsDomainIs(host, "." + dominated[i])) {
            return "PROXY 127.0.0.1:8080";
        }
    }

    return "DIRECT";
}
