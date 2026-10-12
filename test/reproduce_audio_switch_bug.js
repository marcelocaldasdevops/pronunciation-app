const { chromium } = require('playwright');

async function reproduceBug() {
  console.log('🚀 Reproduzindo o bug de alternância de áudio...');
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
    console.log('1. Acessando aplicação...');
    await page.goto('http://localhost:8080', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    // Ativar semântica do Flutter
    await page.evaluate(() => {
      const btn = document.querySelector('flt-semantics-placeholder');
      if (btn) btn.click();
    });
    await page.waitForTimeout(1000);

    console.log('2. Indo para a tela Minha Frase...');
    const minhaFraseBtn = page.getByRole('button', { name: 'Minha Frase', exact: true });
    await minhaFraseBtn.click();
    await page.waitForTimeout(1000);

    console.log('3. Selecionando frase...');
    const phraseChip = page.getByRole('button', { name: 'Water is essential for life' });
    await phraseChip.click();
    await page.waitForTimeout(800);

    console.log('4. Gravando voz...');
    const recordBtn = page.getByRole('button', { name: 'Gravar Minha Voz' });
    await recordBtn.click();
    await page.waitForTimeout(2500);

    console.log('5. Concluindo gravação...');
    const stopBtn = page.getByRole('button', { name: 'Toque para concluir análise' });
    await stopBtn.click();
    await page.waitForTimeout(2000);

    const minhaVozBtn = page.getByRole('button', { name: 'Minha Voz' });
    const isMinhaVozVisible = await minhaVozBtn.isVisible();
    console.log(`Estado antes do clique em Modelo: 'Minha Voz' visível? ${isMinhaVozVisible}`);
    await page.screenshot({ path: 'test_bug_before_model_click.png' });

    console.log('6. Clicando no botão Modelo Nativo...');
    const modeloBtn = page.getByRole('button', { name: 'Modelo Nativo' });
    await modeloBtn.click();
    await page.waitForTimeout(1500);

    const isMinhaVozStillVisible = await minhaVozBtn.isVisible();
    console.log(`Estado APÓS o clique em Modelo: 'Minha Voz' AINDA visível? ${isMinhaVozStillVisible}`);
    await page.screenshot({ path: 'test_bug_after_model_click.png' });

    if (!isMinhaVozStillVisible) {
      console.log('❌ BUG REPRODUZIDO COM SUCESSO: O botão Minha Voz e os resultados desapareceram da tela!');
    } else {
      console.log('Botão Minha Voz permaneceu visível.');
    }
  } catch (err) {
    console.error('Erro na execução:', err);
  } finally {
    await browser.close();
  }
}

reproduceBug();
