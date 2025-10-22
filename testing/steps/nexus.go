package steps

import (
	"context"
	"time"

	"github.com/AlaudaDevops/bdd/asserts"
	"github.com/AlaudaDevops/bdd/logger"
	"github.com/AlaudaDevops/bdd/steps/kubernetes/resource"
	"github.com/cucumber/godog"
	"go.uber.org/zap"
)

// Steps provides Kubernetes resource management step definitions
type Steps struct {
}

// InitializeSteps registers resource assertion and import steps
func (cs Steps) InitializeSteps(ctx context.Context, scenarioCtx *godog.ScenarioContext) context.Context {
	scenarioCtx.Step(`^"([^"]*)" 实例资源检查通过$`, stepNexusResourceConditionCheck)
	return ctx
}

func stepNexusResourceConditionCheck(ctx context.Context, instanceName string) (context.Context, error) {
	log := logger.LoggerFromContext(ctx)
	checks := getInstanceChecks(ctx, instanceName)
	for _, check := range checks {
		_, err := resource.AssertResource(ctx, check)
		if err != nil {
			log.Error("check Nexus instance condition failed", zap.Error(err), zap.String("name", check.Name))
			return ctx, err
		}
	}
	return ctx, nil
}

func getConditionCheck(instanceName, condition string) resource.Assert {
	return resource.Assert{
		AssertBase: resource.AssertBase{
			Resource: resource.Resource{
				Name:       instanceName,
				Kind:       "Nexus",
				APIVersion: "operator.alaudadevops.io/v1alpha1",
			},
			PathValue: asserts.PathValue{
				Path:  "$.status.conditions[?(@.type == '" + condition + "')][0].status",
				Value: "true",
			},
		},
		CheckTime: resource.CheckTime{
			Timeout:  10 * time.Minute,
			Interval: 20 * time.Second,
		},
	}
}

func getInstanceChecks(_ context.Context, instanceName string) []resource.Assert {
	return []resource.Assert{
		getConditionCheck(instanceName, "Initialized"),
		getConditionCheck(instanceName, "Deployed"),
		getConditionCheck(instanceName, "Running"),
	}
}
