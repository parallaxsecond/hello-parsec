// Copyright 2022 Contributors to the Parsec project.
// SPDX-License-Identifier: Apache-2.0

use parsec_client::core::interface::operations::psa_algorithm::AsymmetricEncryption;
use parsec_client::BasicClient;

use std::io::stdin;

const APPLICATION_NAME: &str = "HelloParsec";
const KEY_NAME: &str = "HelloParsecDemoKey";

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let basic_client = BasicClient::new(Some(String::from(APPLICATION_NAME)))?;

    let mut input_data: String = String::new();

    stdin().read_line(&mut input_data)?;

    let input = base64::decode(input_data.trim().as_bytes().to_vec())?;

    let plaintext = basic_client.psa_asymmetric_decrypt(
        KEY_NAME,
        AsymmetricEncryption::RsaPkcs1v15Crypt,
        &input,
        None,
    )?;
    let plaintext = String::from_utf8_lossy(&plaintext).to_string();

    println!("{}", plaintext);

    Ok(())
}
