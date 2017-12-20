const INPUT: &'static str = "6592822488931338589815525425236818285229555616392928433262436847386544514648645288129834834862363847542262953164877694234514375164927616649264122487182321437459646851966649732474925353281699895326824852555747127547527163197544539468632369858413232684269835288817735678173986264554586412678364433327621627496939956645283712453265255261565511586373551439198276373843771249563722914847255524452675842558622845416218195374459386785618255129831539984559644185369543662821311686162137672168266152494656448824719791398797359326412235723234585539515385352426579831251943911197862994974133738196775618715739412713224837531544346114877971977411275354168752719858889347588136787894798476123335894514342411742111135337286449968879251481449757294167363867119927811513529711239534914119292833111624483472466781475951494348516125474142532923858941279569675445694654355314925386833175795464912974865287564866767924677333599828829875283753669783176288899797691713766199641716546284841387455733132519649365113182432238477673375234793394595435816924453585513973119548841577126141962776649294322189695375451743747581241922657947182232454611837512564776273929815169367899818698892234618847815155578736875295629917247977658723868641411493551796998791839776335793682643551875947346347344695869874564432566956882395424267187552799458352121248147371938943799995158617871393289534789214852747976587432857675156884837634687257363975437535621197887877326295229195663235129213398178282549432599455965759999159247295857366485345759516622427833518837458236123723353817444545271644684925297477149298484753858863551357266259935298184325926848958828192317538375317946457985874965434486829387647425222952585293626473351211161684297351932771462665621764392833122236577353669215833721772482863775629244619639234636853267934895783891823877845198326665728659328729472456175285229681244974389248235457688922179237895954959228638193933854787917647154837695422429184757725387589969781672596568421191236374563718951738499591454571728641951699981615249635314789251239677393251756396";

struct PairIterator<'a> {
    values: &'a [u8],
    head: usize,
    offset: usize
}

trait PairIterable {
    fn pair_iter(&self, offset:usize) -> PairIterator;
}

impl<'a> Iterator for PairIterator<'a> {
    type Item = (u8, u8);

    fn next(&mut self) -> Option<Self::Item> {
        if self.head >= self.values.len() {
            return None
        }

        let right_index = (self.head + self.offset) % self.values.len();
        let values = (self.values[self.head], self.values[right_index]);
        self.head += 1;

        Some(values)
    }
}

impl PairIterable for [u8] {
    fn pair_iter(&self, offset: usize) -> PairIterator {
        PairIterator {
            values: &self,
            head: 0,
            offset: offset
        }
    }
}

fn compute_sum(values: &[u8], offset: usize) -> u32 {
    let mut sum: u32 = 0;

    for index0 in 0..values.len() {
        let index1 = (index0 + offset) % values.len();

        let lhs = values[index0];
        let rhs = values[index1];

        if lhs == rhs {
            sum += (lhs as u32) - 48;
        }
    }

    sum
}

fn compute_sum_2(values: &[u8], offset: usize) -> u32 {
    values
        .pair_iter(offset)
        .fold(0, |acc: u32, (lhs, rhs)| {
            if lhs == rhs {
                acc + (lhs as u32) - 48
            } else {
                acc
            }
        })
}

fn main() {
    let bytes = INPUT.as_bytes();

    let first_sum_1 = compute_sum(bytes, 1);
    let first_sum_2 = compute_sum_2(bytes, 1);

    println!("First sum: {} - {}", first_sum_1, first_sum_2);

    let second_sum_1 = compute_sum(bytes, bytes.len() / 2);
    let second_sum_2 = compute_sum_2(bytes, bytes.len() / 2);

    println!("Second sum: {} - {}", second_sum_1, second_sum_2);
}
