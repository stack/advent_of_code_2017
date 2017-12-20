use std::io::BufRead;

fn checksum(spreadsheet: &Vec<Vec<i32>>, filter: fn(&Vec<i32>) -> Option<i32>) -> i32 {
    spreadsheet
        .iter()
        .map(|row| filter(&row).unwrap())
        .sum()
}

fn divisible(row: &Vec<i32>) -> Option<i32> {
    let mut values = row.clone();
    values.sort();

    for (idx, smaller) in values.iter().enumerate() {
        for larger in &values[(idx + 1)..] {
            if larger % smaller == 0 {
                return Some(larger / smaller);
            }
        }
    }

    None
}

fn min_max_diff(row: &Vec<i32>) -> Option<i32> {
    let mut min = std::i32::MAX;
    let mut max = std::i32::MIN;

    for &value in row {
        if value < min {
            min = value;
        }

        if value > max {
            max = value;
        }
    }

    Some(max - min)
}

fn main() {
    // Get the spreadsheet from STDIN
    let stdin = std::io::stdin();
    let spreadsheet: Vec<Vec<i32>> = stdin
        .lock()
        .lines()
        .map(|line| {
            line
                .unwrap()
                .split_whitespace()
                .map(|v| v.parse::<i32>().unwrap())
                .collect()
        })
        .collect();

    let sum = checksum(&spreadsheet, min_max_diff);
    println!("Checksum: {}", sum);

    let sum = checksum(&spreadsheet, divisible);
    println!("Checksum 2: {}", sum);
}
