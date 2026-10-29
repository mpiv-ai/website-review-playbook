// DNS lookups in `dig +short` style, for computers without dig (Windows).
// Uses the system's DNS servers, like dig. DS (DNSSEC) needs dig.
// Usage: node dns-lookup.mjs <A|AAAA|NS|MX|CAA|TXT|CNAME|DS> <name>
import { promises as dns } from "node:dns";

const [type = "", name = ""] = process.argv.slice(2);
const fqdn = (h) => (h.endsWith(".") ? h : `${h}.`);
const caa = (r) => Object.entries(r).filter(([k]) => !["critical", "type"].includes(k)).map(([k, v]) => `${r.critical} ${k} "${v}"`);

// Like dig, list the CNAME chain before the records it leads to.
const chain = async (n) => {
  const hops = [];
  for (let i = 0; i < 8; i++) {
    const [next] = await dns.resolveCname(n).catch(() => []);
    if (!next) break;
    hops.push(fqdn(next));
    n = next;
  }
  return hops;
};
const viaCname = (resolve) => async (n) => {
  const hops = await chain(n);
  try {
    return [...hops, ...(await resolve(n))];
  } catch (e) {
    if (hops.length && ["ENODATA", "ENOTFOUND"].includes(e.code)) return hops;
    throw e;
  }
};

const lookups = {
  A: viaCname((n) => dns.resolve4(n)),
  AAAA: viaCname((n) => dns.resolve6(n)),
  NS: viaCname(async (n) => (await dns.resolveNs(n)).map(fqdn)),
  MX: viaCname(async (n) => (await dns.resolveMx(n)).map((r) => `${r.priority} ${fqdn(r.exchange)}`)),
  CAA: viaCname(async (n) => (await dns.resolveCaa(n)).flatMap(caa)),
  TXT: viaCname(async (n) => (await dns.resolveTxt(n)).map((chunks) => chunks.map((c) => `"${c}"`).join(" "))),
  CNAME: async (n) => (await dns.resolveCname(n)).map(fqdn),
  DS: async () => ["(DS lookup needs dig; DNSSEC not checked on this computer)"],
};

const lookup = lookups[type.toUpperCase()];
if (!lookup || !/^[A-Za-z0-9_]([A-Za-z0-9_.-]*[A-Za-z0-9])?$/.test(name)) {
  console.error(`usage: node dns-lookup.mjs <${Object.keys(lookups).join("|")}> <name>`);
  process.exit(2);
}

try {
  for (const line of await lookup(name)) console.log(line);
} catch (e) {
  // No such name or no records of this type: print nothing, as `dig +short` does.
  if (!["ENODATA", "ENOTFOUND"].includes(e.code)) console.error(`;; ${type} ${name}: ${e.code || e.message}`);
}
