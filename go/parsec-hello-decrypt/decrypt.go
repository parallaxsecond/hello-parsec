// Copyright 2022 Contributors to the Parsec project.
// SPDX-License-Identifier: Apache-2.0

package main

import (
	"bufio"
	"encoding/base64"
	"fmt"
	"os"
	"strings"

	parsec "github.com/parallaxsecond/parsec-client-go/parsec"
	"github.com/parallaxsecond/parsec-client-go/parsec/algorithm"
)

func main() {
	var basicClient *parsec.BasicClient
	basicClient, _ = parsec.CreateConfiguredClient("HelloParsec")

	input, _ := bufio.NewReader(os.Stdin).ReadString('\n')
	ciphertext, _ := base64.StdEncoding.DecodeString(strings.TrimSpace(input))
	plaintext, err := basicClient.PsaAsymmetricDecrypt("HelloParsecDemoKey", algorithm.NewAsymmetricEncryption().RsaPkcs1V15Crypt().GetAsymmetricEncryption(), nil, ciphertext)
	if err == nil {
		fmt.Println(string(plaintext))
	} else {
		fmt.Println("An error occurred in the Go decryption sample program:")
		fmt.Println(err)
	}
}
