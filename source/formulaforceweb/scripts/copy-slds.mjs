// An example script to copy the SLDS resources into your app
// my-app/scripts/copy-slds.mjs
import cpx from 'cpx';
cpx.copy('./node_modules/@salesforce-ux/design-system/assets/**/*', 'src/assets', () => {
    console.log('Done copying SLDS resources');
});
