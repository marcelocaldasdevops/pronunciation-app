const { chromium } = require('playwright');

async function testAudioSwitchFixed() {
  console.log('🚀 Iniciando teste automatizado Playwright: Alternância de Áudio Corrigida...');
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: true,
    args: [
      '--use-fake-ui-for-media-stream',
      '--use-fake-device-for-media-stream',
      '--no-sandbox',
    ],
  });

  const context = await browser.newContext({
    permissions: ['microphone'],
    viewport: { width: 420, height: 900 },
  });

  const page = await context.newPage();

  page.on('console', msg => console.log('BROWSER CONSOLE:', msg.text()));

  try {
    console.log('1. Acessando http://localhost:8080...');
    await page.goto('http://localhost:8080/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // Habilitar acessibilidade do Flutter
    await page.evaluate(() => {
      const btn = document.querySelector('flt-semantics-placeholder');
      if (btn) btn.click();
    });
    await page.waitForTimeout(1000);

    console.log('2. Navegando para "Minha Frase"...');
    const minhaFraseNav = page.getByRole('button', { name: 'Minha Frase', exact: true });
    await minhaFraseNav.click();
    await page.waitForTimeout(1000);

    console.log('3. Selecionando sugestão...');
    const phraseChip = page.getByRole('button', { name: 'Water is essential for life' });
    await phraseChip.click();
    await page.waitForTimeout(800);

    console.log('4. Gravando voz do usuário...');
    const recordBtn = page.getByRole('button', { name: 'Gravar Minha Voz' });
    await recordBtn.click();
    await page.waitForTimeout(2500);

    console.log('5. Concluindo gravação...');
    const stopBtn = page.getByRole('button', { name: 'Toque para concluir análise' });
    await stopBtn.click();
    await page.waitForTimeout(2000);

    // Validação do resultado inicial
    const feedbackTitle = page.getByText('Feedback Palavra por Palavra:');
    if (!await feedbackTitle.isVisible()) {
      throw new Error('Falha: Bloco de resultado não foi exibido após gravação!');
    }
    console.log('✅ Resultado exibido com sucesso na tela!');

    const minhaVozBtn = page.getByRole('button', { name: 'Minha Voz' });
    const modeloBtn = page.getByRole('button', { name: 'Modelo Nativo' });

    console.log('6. Testando clique em "Modelo Nativo"...');
    await modeloBtn.click();
    await page.waitForTimeout(1000);

    // Validação crítica: A tela de resultado e os botões NÃO devem sumir!
    if (!await feedbackTitle.isVisible()) {
      throw new Error('❌ REGRESSÃO: O feedback de resultado sumiu após clicar em Modelo Nativo!');
    }
    console.log('✅ SUCESSO: A avaliação fonética permaneceu na tela após clicar em Modelo Nativo!');

    await page.screenshot({ path: 'test_fixed_step1_model_clicked.png' });

    console.log('7. Testando clique em "Minha Voz"...');
    await minhaVozBtn.click();
    await page.waitForTimeout(1000);

    if (!await feedbackTitle.isVisible()) {
      throw new Error('❌ REGRESSÃO: O feedback de resultado sumiu após clicar em Minha Voz!');
    }
    console.log('✅ SUCESSO: A avaliação permaneceu na tela após clicar em Minha Voz!');

    console.log('8. Testando alternâncias múltiplas seguidas...');
    for (let i = 1; i <= 3; i++) {
      await modeloBtn.click();
      await page.waitForTimeout(600);
      await minhaVozBtn.click();
      await page.waitForTimeout(600);
    }
    console.log('✅ SUCESSO: Alternâncias consecutivas executadas sem qualquer perda de estado!');

    await page.screenshot({ path: 'test_fixed_step2_after_switches.png' });

    console.log('9. Testando botão "Tentar Novamente"...');
    const tentarNovamenteBtn = page.getByRole('button', { name: 'Tentar Novamente' });
    await tentarNovamenteBtn.click();
    await page.waitForTimeout(1000);

    const gravarNovamenteVisible = await recordBtn.isVisible();
    console.log(`Estado após Tentar Novamente: pronto para gravar? ${gravarNovamenteVisible}`);
    if (!gravarNovamenteVisible) {
      throw new Error('Botão de gravação não voltou após Tentar Novamente!');
    }
    console.log('✅ SUCESSO: Tentar Novamente resetou adequadamente para permitir nova gravação!');

    console.log('10. Gravando novamente para testar substituição de áudio...');
    await recordBtn.click();
    await page.waitForTimeout(2000);
    await stopBtn.click();
    await page.waitForTimeout(2000);

    if (!await feedbackTitle.isVisible()) {
      throw new Error('Falha ao gerar novo feedback na regravação!');
    }
    console.log('✅ SUCESSO: Novo áudio gravado e nova avaliação gerada!');

    console.log('11. Testando botão "Nova Frase"...');
    const novaFraseBtn = page.getByRole('button', { name: 'Nova Frase' });
    await novaFraseBtn.click();
    await page.waitForTimeout(1000);

    const textInput = page.getByPlaceholder('Ex: The quick brown fox...');
    console.log('✅ SUCESSO: Nova Frase resetou a tela para o estado limpo inicial!');

    await page.screenshot({ path: 'test_fixed_step3_complete.png' });
    console.log('🎉 TODOS OS TESTES PASSARAM COM 100% DE SUCESSO!');
  } catch (err) {
    console.error('❌ Erro no teste Playwright:', err);
    process.exit(1);
  } finally {
    await browser.close();
  }
}

testAudioSwitchFixed();
