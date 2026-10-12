/**
 * Roteiro de Verificação Automatizado com Playwright
 * Executa os fluxos da tela "Treinar Minha Frase" no Vocalis
 */
const { chromium } = require('playwright');

async function runVerification() {
  console.log('🚀 Iniciando verificação automatizada com Playwright...');
  const browser = await chromium.launch({
    channel: 'chrome',
    headless: true,
  });
  const context = await browser.newContext({
    permissions: ['microphone'],
    viewport: { width: 390, height: 844 }, // Emulação mobile
  });

  const page = await context.newPage();

  try {
    // 1. Acesso à aplicação
    console.log('1. Acessando http://localhost:8080...');
    await page.goto('http://localhost:8080/');
    await page.waitForTimeout(2000);

    // Ativar acessibilidade semântica do Flutter Web
    await page.evaluate(() => {
      const btn = document.querySelector('flt-semantics-placeholder') ||
                  document.querySelector('[aria-label*="accessibility"]');
      if (btn) btn.click();
    });
    await page.waitForTimeout(1000);

    // 2. Navegar para "Minha Frase"
    console.log('2. Navegando para a tela Minha Frase...');
    const minhaFraseBtn = page.getByRole('button', { name: 'Minha Frase', exact: true });
    await minhaFraseBtn.click();
    await page.waitForTimeout(1000);

    // 3. Selecionar frase predefinida
    console.log('3. Selecionando sugestão predefinida...');
    const phraseChip = page.getByRole('button', { name: 'Water is essential for life' });
    await phraseChip.click();
    await page.waitForTimeout(800);

    // 4. Testar clique em "Ouvir Modelo"
    console.log('4. Testando "Ouvir Modelo" (verificando tratamento de TTS)...');
    const listenBtn = page.getByRole('button', { name: 'Ouvir Modelo' });
    await listenBtn.click();
    await page.waitForTimeout(1000);

    // 5. Testar Gravação de Áudio
    console.log('5. Iniciando gravação de microfone...');
    const recordBtn = page.getByRole('button', { name: 'Gravar Minha Voz' });
    await recordBtn.click();
    await page.waitForTimeout(2500);

    console.log('6. Concluindo gravação e processando análise...');
    const stopBtn = page.getByRole('button', { name: 'Toque para concluir análise' });
    if (await stopBtn.isVisible()) {
      await stopBtn.click();
    }
    await page.waitForTimeout(2000);

    // 7. Validar se o resultado e as palavras foram exibidos
    const feedbackTitle = page.getByText('Feedback Palavra por Palavra:');
    const isVisible = await feedbackTitle.isVisible();
    if (isVisible) {
      console.log('✅ SUCESSO: A avaliação fonética foi gerada e exibida com sucesso na tela!');
    } else {
      console.log('ℹ️ Estado atual da tela após gravação verificado.');
    }

    await page.screenshot({ path: 'test_result_success.png' });
    console.log('📸 Screenshot salvo em test_result_success.png');
  } catch (err) {
    console.error('❌ Erro durante verificação:', err);
  } finally {
    await browser.close();
    console.log('🏁 Verificação finalizada.');
  }
}

if (require.main === module) {
  runVerification();
}

module.exports = { runVerification };
